# == Schema Information

# Table name: user_sectors

# user_id                 :bigint   not null
# sector_id               :bigint   not null
# status                  :integer  not null, default 0, options: { inactive: 0, active: 1 }
#
  
class UserSector < ApplicationRecord
  # Relaciones
  belongs_to :user
  belongs_to :sector, counter_cache: true

  enum status: { inactive: 0, active: 1 }

  # Validaciones
  validates_presence_of :user, :sector
end
