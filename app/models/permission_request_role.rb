class PermissionRequestRole < ApplicationRecord
  belongs_to :permission_request, dependent: :destroy
  belongs_to :role
end
