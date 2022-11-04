# == Schema Information

# Table name: user_sectors

# user_id                 :bigint   not null
# sector_id               :bigint   not null
#
  
class UserSector < ApplicationRecord
  # Relaciones
  belongs_to :user
  belongs_to :sector, counter_cache: true

  # Validaciones
  validates_presence_of :user, :sector
end
