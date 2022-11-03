# == Schema Information

# Table name: permission_roles

# id                      :bigint   not null, primary key
# permission_id           :bigint   not null
# role_id                 :bigint   not null
#

class PermissionRole < ApplicationRecord
  belongs_to :role
  belongs_to :permission
end
