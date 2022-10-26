class PermissionRequestRole < ApplicationRecord
  belongs_to :permission_request
  belongs_to :role
end
