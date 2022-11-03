# == Schema Information

# Table name: patients

# id                      :bigint     not null, primary key
# first_name              :string     not null
# last_name               :string     not null
# dni                     :string     not null
# sex                     :integer    not null, by default 0
# birthdate               :datetime   optional
# email                   :string     optional
# marital_status          :integer    not null, by default 1
# status                  :integer    not null, by default 0
# cuil                    :string     optional
# address_id              :bigint     not null, unity
# andes_id                :bigint     not null, area
# bed_id                  :bigint     optional
#

class Patient < ApplicationRecord
  include PgSearch::Model
  include QuerySort
  enum status: { Temporal: 0, Validado: 1 }
  enum sex: { Otro: 1, Femenino: 2, Masculino: 3 }
  enum marital_status: { soltero: 1, casado: 2, separado: 3, divorciado: 4, viudo: 5, otro: 6 }

  # Relationships
  belongs_to :address, optional: true
  belongs_to :bed, optional: true
  has_many :outpatient_prescriptions, dependent: :destroy
  has_many :chronic_prescriptions, dependent: :destroy
  has_many :inpatient_prescriptions, dependent: :destroy
  has_one_base64_attached :avatar
  has_one_attached :file
  has_many :patient_phones, dependent: :destroy
  has_many :inpatient_movements
  before_save :format_full_name
  # Validations
  validates_presence_of :first_name, :last_name, :dni, :birthdate
  validates_uniqueness_of :dni
  validates :dni, numericality: { only_integer: true }
  validates_associated :patient_phones

  # Delegations
  delegate :country_name, :state_name, :city_name, :line, to: :address, prefix: :address

  accepts_nested_attributes_for :patient_phones,
                                reject_if: proc { |attributes| attributes['number'].blank? },
                                allow_destroy: true

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, :dni, :status, :sex, :birthdate, :first_name, :last_name)
    query = query.like_dni(filter_params[:dni]) if filter_params.present? && filter_params[:dni].present?
    if filter_params.present? && filter_params[:full_name].present?

      query = query.like_full_name(filter_params[:full_name])
    end
    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(first_name: :desc)
            end

    return query
  }

  pg_search_scope :get_by_dni_and_fullname,
                  against: %i[dni first_name last_name],
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :like_dni, lambda { |dni|
    where('dni LIKE ?', "%#{dni}%")
  }
  scope :like_full_name, lambda { |word|
                           where('unaccent(lower(patients.first_name))  like ? or unaccent(lower(patients.last_name))  like ? or unaccent(lower(CONCAT(patients.last_name,\' \',patients.first_name)))  like ?', "%#{word.downcase.removeaccents}%", "%#{word.downcase.removeaccents}%", "%#{word.downcase.removeaccents}%")
                         }

  # Get all dispensed patients by a sector: OutPatientPrescriptions / ChronicPrescriptions
  scope :filter_by_sector_dispensation, lambda { |filter_params|
    query = by_stock(filter_params[:sector_id])
    if filter_params[:patient].present?
      query = query.where('unaccent(lower(last_name)) like ? OR unaccent(lower(first_name)) like ? OR unaccent(lower(dni)) like ?',
                          "%#{filter_params[:patient].downcase.parameterize(separator: ' ')}%",
                          "%#{filter_params[:patient].downcase.parameterize(separator: ' ')}%",
                          "%#{filter_params[:patient]}%")
    end
    query = query.where.not(id: filter_params[:patients_ids]) if filter_params[:patients_ids]
    return query
  }

  scope :by_stock, lambda { |sector_id|
    op_patient_ids = OutpatientPrescription.where(provider_sector_id: sector_id, status: 'dispensada').pluck(:patient_id).uniq
    cr_patient_ids = ChronicPrescription.where(provider_sector_id: sector_id, status: %w[dispensada dispensada_parcial]).pluck(:patient_id).uniq
    patient_ids = (op_patient_ids + cr_patient_ids).uniq
    where(id: patient_ids)
  }

  def full_info
    "#{last_name} #{first_name} #{dni}"
  end

  def fullname
    last_name + ', ' + first_name
  end

  def age_string
    if birthdate.present?
      age = ((Time.zone.now - birthdate.to_time) / 1.year.seconds).floor
      age.to_s + ' años'
    else
      '----'
    end
  end

  # Return formatted birthdate
  def birthdate_string
    birthdate.present? ? birthdate.strftime('%d/%m/%Y') : '---'
  end

  # Return the last hospitalization
  def last_hospitalization
    inpatient_movements.admissions.last
  end

  def format_full_name
    self.first_name = first_name.downcase.to_permite_accents
    self.last_name = last_name.downcase.to_permite_accents
  end
end
