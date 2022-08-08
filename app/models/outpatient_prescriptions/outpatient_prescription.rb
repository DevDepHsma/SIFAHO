class OutpatientPrescription < ApplicationRecord
  include PgSearch::Model
  include QuerySort

  # Statuses
  enum status: { pendiente: 0, dispensada: 1, vencida: 2 }

  # Relationships
  belongs_to :professional
  belongs_to :patient
  belongs_to :provider_sector, class_name: 'Sector', optional: true
  belongs_to :establishment

  has_many :outpatient_prescription_products, dependent: :destroy
  has_many :products, through: :outpatient_prescription_products
  has_many :movements, class_name: 'OutpatientPrescriptionMovement'
  has_many :stock_movements, as: :order, dependent: :destroy, inverse_of: :order

  # Validations
  validates_presence_of :patient_id, :professional_id, :date_prescribed, :remit_code
  validates_associated :outpatient_prescription_products
  validates_uniqueness_of :remit_code
  validate :presence_of_products_into_the_order
  validate :date_prescribed_in_range

  # Nested attributes
  accepts_nested_attributes_for :outpatient_prescription_products,
                                allow_destroy: true

  # Delegations
  delegate :fullname, :last_name, :dni, :age_string, to: :patient, prefix: :patient, allow_nil: true
  delegate :qualifications, :fullname, to: :professional, prefix: :professional

  # filterrific(
  #   default_filter_params: { sorted_by: 'updated_at_desc' },
  #   available_filters: %i[search_by_remit_code search_by_professional search_by_patient sorted_by with_order_type
  #                         date_prescribed_since for_statuses]
  # )

  # SCOPES #--------------------------------------------------------------------

  # pg_search_scope :search_name,
  # against: :name,
  # :using => {
  #   :tsearch => { :prefix => true } # Buscar coincidencia desde las primeras letras.
  # },
  # :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_by_professional,
                  associated_against: { professional: %i[fullname] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_by_patient,
                  associated_against: { patient: %i[last_name first_name dni] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  # Metodo para establecer las opciones del select sorted_by
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Modificación (nueva primero)', 'updated_at_desc'],
      ['Modificación (antigua primero)', 'updated_at_asc'],
      ['Creación (nueva primero)', 'created_at_desc'],
      ['Creación (antigua primero)', 'created_at_asc'],
      ['Medico (a-z)', 'medico_asc'],
      ['Medico (z-a)', 'medico_desc'],
      ['Paciente (a-z)', 'paciente_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Productos (mayor primero)', 'productos_desc'],
      ['Productos (menor primero)', 'productos_asc'],
      ['Movimientos (mayor primero)', 'movimientos_desc'],
      ['Movimientos (menor primero)', 'movimientos_asc'],
      ['Fecha recetada (nueva primero)', 'recetada_asc'],
      ['Fecha recetada (antigua primero)', 'recetada_desc']
    ]
  end

  def self.options_for_status
    [
      %w[Pendiente pendiente secondary],
      %w[Dispensada dispensada success],
      %w[Vencida vencida danger]
    ]
  end

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, :remit_code, :status, :date_prescribed, 'professionals.fullname AS pr_fullname', 'patients.first_name AS pa_first_name', 'patients.last_name AS pa_last_name', 'patients.dni AS pa_dni').joins(:establishment, :professional, :patient)
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
    where('unaccent(lower(professionals.fullname)) LIKE ?', "%#{word.downcase.parameterize}%")
  }

  # Where string match with %...% (support accents / unaccents)
  scope :like_patient_full_name_and_dni, lambda { |word|
    where('unaccent(lower(patients.first_name)) LIKE ? OR unaccent(lower(patients.last_name)) LIKE ? OR unaccent(lower(patients.dni)) LIKE ?', "%#{word.downcase.parameterize}%", "%#{word.downcase.parameterize}%", "%#{word.downcase.parameterize}%")
  }

  scope :like_date_prescribed_since, lambda { |reference_time|
    where('date_prescribed >= ?', reference_time)
  }

  scope :like_date_prescribed_to, lambda { |reference_time|
    where('date_prescribed <= ?', reference_time)
  }

  # scope :search_by_status, lambda { |status|
  #   where('outpatient_prescriptions.status = ?', status)
  # }

  scope :for_statuses, lambda { |values|
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  }

  scope :with_establishment, lambda { |a_establishment|
    where('outpatient_prescriptions.establishment_id = ?', a_establishment)
  }

  # scope :with_patient_id, lambda { |an_id|
  #   where(patient_id: [*an_id])
  # }

  # Metodos públicos #----------------------------------------------------------
  def sum_to?(a_sector)
    return true if dispensada? && !(provider_sector == a_sector)
  end

  def delivered_with_sector?(a_sector)
    return provider_sector == a_sector if dispensada? || dispensada_parcial?
  end

  def professional_fullname
    professional.full_name
  end

  # Cambia estado a "dispensada" y descuenta la cantidad a los lotes de insumos
  def dispense_by(a_user)
    raise ArgumentError, 'No es posible dispensar recetas vencidas.' if expiry_date < Date.today

    outpatient_prescription_products.each do |opp|
      opp.decrement_stock
    end
    create_notification(a_user, 'dispensó')
  end

  # Método para retornar pedido a estado anterior
  def return_dispensation(a_user)
    if dispensada?
      self.status = 'pendiente'
      outpatient_prescription_products.each do |opp|
        opp.increment_stock
      end
      save!(validate: false)
      create_notification(a_user, 'retornó a un estado anterior')
    else
      raise ArgumentError, 'No es posible retornar a un estado anterior'
    end
  end

  # Label del estado para vista.
  def status_label
    if dispensada?
      'success'
    elsif pendiente?
      'default'
    elsif vencida?
      'danger'
    end
  end

  def sent_date
    dispensed_at
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

  # Métodos de clase #----------------------------------------------------------
  def self.current_day
    where('date_prescribed >= :today', { today: DateTime.now.beginning_of_day })
  end

  def self.last_week
    where('date_prescribed >= :last_week', { last_week: 1.weeks.ago.midnight })
  end

  def self.current_year
    where('date_prescribed >= :year', { year: DateTime.now.beginning_of_year })
  end

  def self.current_month
    where('date_prescribed >= :month', { month: DateTime.now.beginning_of_month })
  end

  def create_notification(of_user, action_type)
    OutpatientPrescriptionMovement.create(user: of_user, outpatient_prescription: self, action: action_type,
                                          sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where(actor: of_user, user: user, target: self, notify_type: 'ambulatoria',
                                action_type: action_type, actor_sector: of_user.sector).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def update_status
    self.status = 'vencida' if pendiente? && date_prescribed < Date.today.months_ago(1)
  end

  def pa_full_info
    "#{pa_last_name} #{pa_first_name} #{pa_dni}"
  end

  private

  def presence_of_products_into_the_order
    if outpatient_prescription_products.size == 0
      errors.add(:presence_of_products_into_the_order, 'Debe agregar almenos 1 producto')
    end
  end

  def date_prescribed_in_range
    # validamos que la fecha de la prescripcion se encuentre en un rango de menor igual a HOY
    # y HOY - 1 MES atras.
    unless date_prescribed >= (Date.today.months_ago(1)) && date_prescribed <= Date.today
      errors.add(:date_prescribed_in_range, 'Debe seleccionar una fecha válida ')
    end
  end
end
