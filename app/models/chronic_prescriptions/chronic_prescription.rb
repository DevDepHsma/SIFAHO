# == Schema Information

# Table name: chronic_prescriptions

# remit_code                :string   not null, auto
# date_prescribed           :string   not null
# expiry_date               :string   not null, auto from date_prescribed
# status                    :integer  not null, by default 0, options { pendiente: 0, dispensada: 1, dispensada_parcial: 2, vencida: 3 }
# diagnostic                :text     optional
# professional_id           :bigint   not null
# patient_id                :bigint   not null
# provider_sector_id        :bigint   not null, auto
# establishment_id          :bigint   not null, auto
#

class ChronicPrescription < ApplicationRecord
  include PgSearch::Model
  include QuerySort

  enum status: { pendiente: 0, dispensada: 1, dispensada_parcial: 2, vencida: 3 }

  # Relaciones
  belongs_to :professional
  belongs_to :patient
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :chronic_dispensations, dependent: :destroy, inverse_of: 'chronic_prescription'
  has_many :chronic_prescription_products, through: :chronic_dispensations
  has_many :original_chronic_prescription_products, dependent: :destroy, inverse_of: 'chronic_prescription'
  has_many :products, through: :chronic_prescription_products
  has_many :movements, class_name: 'ChronicPrescriptionMovement'

  # Validaciones
  validates_presence_of :patient_id, :professional_id, :date_prescribed, :remit_code
  validates_associated :original_chronic_prescription_products
  validates_uniqueness_of :remit_code
  validate :presence_of_products_into_the_order

  # Atributos anidados
  accepts_nested_attributes_for :original_chronic_prescription_products,
                                allow_destroy: true

  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient
  delegate :qualifications, :fullname, to: :professional, prefix: :professional

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, :remit_code, :status, :date_prescribed, :expiry_date, 'professionals.fullname AS pr_fullname', 'patients.first_name AS pa_first_name', 'patients.last_name AS pa_last_name', 'patients.dni AS pa_dni').joins(:establishment, :professional, :patient)
    if filter_params.present?
      # Remit_code
      query = query.like_remit_code(filter_params['code']) if filter_params['code'].present?
      # Profesisonal
      if filter_params['professional_full_name'].present?
        query = query.like_professional_full_name(filter_params['professional_full_name'])
      end
      # Patient
      if filter_params['patient_full_name'].present?
        query = query.like_patient_full_name_and_dni(filter_params['patient_full_name'])
      end
      # Prescribed since
      if filter_params['date_prescribed_since'].present?
        query = query.like_date_prescribed_since(filter_params['date_prescribed_since'])
      end
      # Prescribed to
      if filter_params['date_prescribed_to'].present?
        query = query.like_date_prescribed_to(filter_params['date_prescribed_to'])
      end
      # Status
      query = query.like_status(filter_params['status']) if filter_params['status'].present?
    end

    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(date_prescribed: :desc, status: :desc)
            end
    return query
  }

  # Where string match with %...% (unsupport accents)
  scope :like_remit_code, lambda { |word|
    where('lower(remit_code) LIKE ?', "%#{word.downcase}%")
  }
  # Where string match with %...% (support accents / unaccents)
  scope :like_professional_full_name, lambda { |word|
    where('unaccent(lower(professionals.fullname)) LIKE ?', "%#{word.downcase.removeaccents}%")
  }
  # Where string match with %...% (support accents / unaccents)
  scope :like_patient_full_name_and_dni, lambda { |word|
    where('unaccent(lower(patients.first_name)) LIKE ? OR unaccent(lower(patients.last_name)) LIKE ? OR unaccent(lower(patients.dni)) LIKE ?',
          "%#{word.downcase.removeaccents}%",
          "%#{word.downcase.removeaccents}%",
          "%#{word.downcase.removeaccents}%")
  }
  scope :like_date_prescribed_since, lambda { |reference_time|
    puts "<===========".colorize(background: :red)
    where('date_prescribed >= ?', reference_time)
  }
  scope :like_date_prescribed_to, lambda { |reference_time|
    where('date_prescribed <= ?', reference_time)
  }
  scope :like_status, lambda { |status|
    where('chronic_prescriptions.status = ?', status)
  }
  scope :pending_count, -> { where('chronic_prescriptions.status = 0').count }
  scope :pending_dispense_count, -> { where('chronic_prescriptions.status = 2').count }
  scope :with_establishment, lambda { |a_establishment|
    where('chronic_prescriptions.establishment_id = ?', a_establishment)
  }

  def self.options_for_statuses
    [
      %w[Pendiente pendiente secondary],
      %w[Dispensada dispensada success],
      ['Dispensada parcial', 'dispensada_parcial', 'primary'],
      %w[Vencida vencida danger]
    ]
  end

  def self.last_week
    where('date_prescribed >= :last_week', { last_week: 1.weeks.ago.midnight })
  end

  # scope :for_statuses, ->(values) do
  #   return all if values.blank?

  #   where(status: statuses.values_at(*Array(values)))
  # end

  def create_notification(of_user, action_type)
    ChronicPrescriptionMovement.create(user: of_user, chronic_prescription: self, action: action_type,
                                       sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: self, notify_type: 'cronica',
                                action_type: action_type, actor_sector: of_user.sector).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  # Actualiza el estado de: ChronicPrescription a "dispensada" y si se completo el ciclo de la receta
  # se actualiza el estado de la receta a "dispensada"
  def dispense_by
    # dispensacion completa: cambio de estado a "dispensada"
    dispensada! if sum_request_quantity <= sum_delivery_quantity
  end

  def return_dispense_by(a_user)
    # dispensacion incompleta con previo estado "dispensada": cambio de estado a "dispensada_parcial"
    update_status
    # if sum_request_quantity > sum_delivery_quantity && self.dispensada?
    #   self.dispensada_parcial!
    # elsif self.chronic_dispensations.count == 0 # && self.dispensada_parcial?
    #   self.pendiente!
    # end

    create_notification(a_user, 'retornó una dispensación')
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    professional.full_info
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    patient.dni.to_s + ' ' + patient.fullname
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end

  # Update status prescription based on expiry date and delivered quantity
  def update_status
    if !vencida? && Date.today > expiry_date
      self.status = 'vencida'
    elsif (sum_request_quantity <= sum_delivery_quantity) || !any_product_without_dispensing?
      self.status = 'dispensada'
    elsif any_product_without_dispensing? && chronic_dispensations.count > 0
      self.status = 'dispensada_parcial'
    elsif chronic_dispensations.count == 0
      self.status = 'pendiente'
    end
  end

  # Return true if all products are 'Terminado' or 'Terminado manual'
  def any_product_without_dispensing?
    original_chronic_prescription_products.for_treatment_statuses(['pendiente']).present?
  end

  # Finish chronic prescription if there any product without dispense
  def finish_by(a_user)
    raise ArgumentError, 'Tratamientos pendientes' if any_product_without_dispensing?

    dispensada!
    create_notification(a_user, 'finalizó la receta')
  end

  def pa_full_info
    "#{pa_last_name} #{pa_first_name} #{pa_dni}"
  end

  private

  def presence_of_products_into_the_order
    if original_chronic_prescription_products.size == 0
      errors.add(:presence_of_products_into_the_order, 'Debe agregar almenos 1 producto')
    end
  end

  # Get total requested quantity of original products
  def sum_request_quantity
    original_chronic_prescription_products.sum(:total_request_quantity)
  end

  # Get total delivered quantity of original products
  def sum_delivery_quantity
    original_chronic_prescription_products.sum(:total_delivered_quantity)
  end
end
