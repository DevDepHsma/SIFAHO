# == Schema Information

# Table name: permission_users

# id                        :bigint   not null
# user_id                   :bigint   not null
# sector_id                 :bigint   not null
# permission_id             :bigint   not null
#

class PermissionUser < ApplicationRecord
  belongs_to :user
  belongs_to :sector
  belongs_to :permission
end
