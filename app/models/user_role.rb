# == Schema Information

# Table name: users

#  user_id                 :bigint, not null
#  role_id                 :bigint, not null
#  sector_id               :bigint, not null

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :sector
end
