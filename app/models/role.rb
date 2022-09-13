class Role < ApplicationRecord
  has_many :permission_request_roles
  has_many :permission_requests, through: :permission_request_roles
end
