class Establishment < ApplicationRecord
  include PgSearch::Model
  include QuerySort
  # Relationships
  has_many :sectors
  has_many :users, through: :sectors
  has_many :prescriptions
  has_many :beds, through: :sectors
  has_many :hospitalized_patients, through: :beds, source: :patient
  has_many :inpatient_prescriptions, through: :hospitalized_patients
  belongs_to :city, optional: true
  belongs_to :sanitary_zone
  belongs_to :establishment_type

  has_one_attached :image

  # Validations
  validates_presence_of :name, :short_name
  validates :sanitary_zone_id, presence: true
  validates :cuie, allow_blank: true, length: { is: 6 }, uniqueness: true
  validates :establishment_type_id, presence: true
  validates :siisa,
            format: { with: /\A\d+\z/, message: 'debe tener solo números.' }
  validates :latitude, numericality: { greater_than_or_equal_to:  -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_cuie,
                  against: :cuie,
                  using: {
                    tsearch: { prefix: true } # Buscar coincidencia desde las primeras letras.
                  },
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true } # Buscar coincidencia desde las primeras letras.
                  },
                  ignoring: :accents # Ignorar tildes.

  scope :where_not_id, lambda { |an_id|
    where.not(id: [*an_id])
  }

  scope :filter_by_params, lambda { |filter_params|
    query = self.select(:id, :cuie, :name, :establishment_type_id)
    query = query.like_cuie(filter_params[:cuie]) if filter_params.present? && filter_params[:cuie].present?
    query = query.like_name(filter_params[:name]) if filter_params.present? && filter_params[:name].present?
    query = if filter_params.present? && filter_params['sort'].present?
              query.sorted_by(filter_params['sort'])
            else
              query.reorder(name: :desc)
            end

    return query
  }

  scope :like_cuie, ->(cuie) { where('cuie::VARCHAR like ?', "%#{cuie}%") }
  scope :like_name, lambda { |name|
                      where('unaccent(lower(name))  like ?', "%#{name.downcase.removeaccents}%")
                    }

  def total_users
    users.distinct('users.id').count
  end

  def self.options_for_sorted_by
    [
      ['Nombre (a-z)', 'nombre_asc'],
      ['Nombre (z-a)', 'nombre_desc'],
      ['Creado (nueva primero)', 'creado_desc'],
      ['Creado (antigua primero)', 'creado_asc'],
      ['Sectores (mayor primero)', 'sectores_desc'],
      ['Sectores (menor primero)', 'sectores_asc'],
      ['Usuarios (mayor primero)', 'usuarios_desc'],
      ['Usuarios (menor primero)', 'usuarios_asc']
    ]
  end

  scope :by_establishment_type, ->(ids_ary) { where(establishment_type: ids_ary) }
end
