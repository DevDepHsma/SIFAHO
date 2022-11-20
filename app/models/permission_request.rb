# == Schema Information

# Table name: permission_requests

# user_id                         :bigint
# status                          :integer, default: 0, options: { in_progress: 0, done: 1, rejected: 2 }
# other_establishment             :string
# other_sector                    :string
# observation                     :text
# aproved_by_id                   :bigint
# establishment_id                :bigint
# sector_id                       :bigint

class PermissionRequest < ApplicationRecord
  include PgSearch::Model

  enum status: { in_progress: 0, done: 1, rejected: 2 }
  # Relationships
  belongs_to :user
  belongs_to :aproved_by, class_name: 'User', optional: true
  has_one :profile, through: :user
  belongs_to :establishment, optional: true
  belongs_to :sector, optional: true
  has_many :permission_request_roles, dependent: :delete_all
  has_many :roles, through: :permission_request_roles

  before_create :clean_establishment
  after_create :set_permission_req_to_user

  # Validations
  validates_presence_of :user
  validates_presence_of :roles
  validates_presence_of :establishment_id, on: :create
  validates_presence_of :sector_id, if: :positive_establishment?
  validates_presence_of :other_establishment, if: :none_establishment?
  validates_presence_of :other_sector, if: :none_sector?

  accepts_nested_attributes_for :roles

  filterrific(
    default_filter_params: { sorted_by: 'fecha_desc' },
    available_filters: %i[
      search_name
      sorted_by
      for_statuses
    ]
  )

  pg_search_scope :search_name,
                  associated_against: { profile: %i[first_name last_name] },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^fecha_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("permission_requests.created_at #{direction}")
    when /^sector_/
      # Ordenamiento por nombre de sector
      reorder("LOWER(permission_requests.sector) #{direction}")
    when /^establecimiento_/
      # Ordenamiento por nombre de establecimiento
      reorder("LOWER(permission_requests.establishment) #{direction}")
    when /^estados_/
      # Ordenamiento por la unidad
      reorder("permission_requests.status #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc']
    ]
  end

  def self.options_for_status
    [
      %w[Nueva in_progress info],
      %w[Terminada done success],
      %w[Rechazada rechazada danger]
    ]
  end

  scope :for_statuses, lambda { |values|
    return all if values.blank?

    where(status: statuses.values_at(*Array(values)))
  }

  def positive_establishment?
    establishment_id.present? && establishment_id.positive?
  end

  def none_establishment?
    establishment_id.present? && establishment_id.zero?
  end

  def none_sector?
    none_establishment? || sector_id.present? && sector_id.zero?
  end

  def clean_establishment
    self.establishment_id = nil if establishment_id.zero?
  end

  def set_permission_req_to_user
    user.permission_req! if user.active?
  end

  def build_user_permissions
    if sector_id.present?
      user.user_sectors.build(sector_id: sector.id)
      user.sector_id = sector.id unless user.sector.present?
    end
    roles.each { |role| user.user_roles.build(role_id: role.id, sector_id: sector.id) } if roles.present?
    user
  end
end
