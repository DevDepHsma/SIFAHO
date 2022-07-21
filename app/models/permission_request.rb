class PermissionRequest < ApplicationRecord
  include PgSearch::Model

  # Relationships
  belongs_to :user
  has_one :profile, through: :user
  belongs_to :establishment, optional: true
  belongs_to :sector, optional: true

  enum status: { in_progress: 0, done: 1 }
  before_create :clean_establishment
  after_create :set_permission_req_to_user

  # Validations
  validates_presence_of :user
  validates_presence_of :establishment_id, on: :create
  validates_presence_of :sector_id, if: :positive_establishment?
  validates_presence_of :other_establishment, if: :none_establishment?
  validates_presence_of :other_sector, if: :none_sector?

  filterrific(
    default_filter_params: { sorted_by: 'fecha_desc' },
    available_filters: [
      :search_name,
      :sorted_by,
      :for_statuses
    ]
  )

  pg_search_scope :search_name,
    :associated_against => { profile: [:first_name, :last_name] },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^fecha_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("permission_requests.created_at #{ direction }")
    when /^sector_/
      # Ordenamiento por nombre de sector
      reorder("LOWER(permission_requests.sector) #{ direction }")
    when /^establecimiento_/
      # Ordenamiento por nombre de establecimiento
      reorder("LOWER(permission_requests.establishment) #{ direction }")
    when /^estados_/
      # Ordenamiento por la unidad
      reorder("permission_requests.status #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
    ]
  end

  def self.options_for_status
    [
      ['Nueva', 'in_progress', 'info'],
      ['Terminada', 'done', 'success'],
      ['Rechazada', 'rechazada', 'danger'],
    ]
  end

  scope :for_statuses, ->(values) do
    return all if values.blank?
    where(status: statuses.values_at(*Array(values)))
  end

  def positive_establishment?
    establishment_id.present? && establishment_id.positive?
  end

  def none_establishment?
    establishment_id.present? && establishment_id.zero?
  end

  def none_sector?
    self.none_establishment? || sector_id.present? && sector_id.zero?
  end

  def clean_establishment
    self.establishment_id = nil if establishment_id.zero?
  end

  def set_permission_req_to_user
    self.user.permission_req! if self.user.active?
  end
end
