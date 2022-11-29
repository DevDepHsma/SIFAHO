# == Schema Information

# Table name: permission_modules

# id                      :bigint   not null, primary key
# name                    :string   not null
#
class PermissionModule < ApplicationRecord
  include PgSearch::Model

  has_many :permissions, dependent: :delete_all

  validates :name, uniqueness: true
  validates_presence_of :name

  pg_search_scope :search_name,
                  against: :name,
                  using: {
                    tsearch: { prefix: true } # Buscar coincidencia desde las primeras letras.
                  },
                  ignoring: :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'name_desc' },
    available_filters: %i[
      search_name
      sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^name_/s
      # Ordenamiento por fecha de creación en la BD
      order("permission_modules.name #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  def permissions_build(user, sector)
    permissions.where
               .not(id: user.permission_users.where(sector: sector)
               .collect(&:permission_id)).map do |permission|
                 user.permission_users.build(sector: sector, permission: permission)
               end
    user.permission_users
        .select do |permission_user|
          if sector.present? && permission_user.sector_id == sector.id && permission_user.permission.permission_module_id == id
            permission_user
          end
        end
        .sort_by { |item| [item.permission.name] }
  end
end
