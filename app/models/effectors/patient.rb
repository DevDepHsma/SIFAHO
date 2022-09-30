class Patient < ApplicationRecord
  include PgSearch::Model

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

  # Validations
  validates_presence_of :first_name, :last_name, :dni
  validates_uniqueness_of :dni
  validates :dni, numericality: { only_integer: true }
  validates_associated :patient_phones

  # Delegations
  delegate :country_name, :state_name, :city_name, :line, to: :address, prefix: :address

  accepts_nested_attributes_for :patient_phones,
                                reject_if: proc { |attributes| attributes['number'].blank? },
                                allow_destroy: true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: %i[
      sorted_by
      search_fullname
      search_dni
    ]
  )
  pg_search_scope :get_by_dni_and_fullname,
                  against: %i[dni first_name last_name],
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_fullname,
                  against: %i[first_name last_name],
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :search_dni, lambda { |query|
    string = query.to_s
    where('dni::text LIKE ?', "%#{string}%")
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("patients.created_at #{direction}")
    when /^nacimiento_/
      # Ordenamiento por fecha de creación en la BD
      order("patients.birthdate #{direction}")
    when /^dni_/
      # Ordenamiento por fecha de creación en la BD
      order("patients.dni #{direction}")
    when /^nombre_/
      # Ordenamiento por nombre de paciente
      order("LOWER(patients.first_name) #{direction}")
    when /^apellido_/
      # Ordenamiento por apellido de paciente
      order("LOWER(patients.last_name) #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }
  scope :filter_by_sector_dispensation, lambda { |filter_params|
    op_patient_ids = OutpatientPrescription.where(provider_sector_id: filter_params[:sector_id], status: 'dispensada').pluck(:patient_id).uniq
    cr_patient_ids = ChronicPrescription.where(provider_sector_id: filter_params[:sector_id], status: ['dispensada', 'dispensada_parcial']).pluck(:patient_id).uniq
    patient_ids = (op_patient_ids + cr_patient_ids).uniq
    query = where(id: patient_ids)
    if filter_params[:patient].present?
      query = query.where('unaccent(lower(last_name)) like ? OR unaccent(lower(first_name)) like ? OR unaccent(lower(dni)) like ?',
                          "%#{filter_params[:patient].downcase.parameterize(separator: ' ')}%",
                          "%#{filter_params[:patient].downcase.parameterize(separator: ' ')}%",
                          "%#{filter_params[:patient]}%")
    end
    query = query.where.not(id: filter_params[:patient_ids]) if filter_params[:patient_ids]
    return query
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Apellido (a-z)', 'apellido_asc']
    ]
  end

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
end
