# == Schema Information

# Table name: roles

# id                      :bigint   not null, primary key
# name                    :string   not null
#
class Role < ApplicationRecord
  has_many :permission_request_roles, dependent: :delete_all
  has_many :permission_requests, through: :permission_request_roles
  has_many :permission_roles, dependent: :delete_all
  has_many :permissions, through: :permission_roles
  has_many :user_roles, dependent: :delete_all
  has_many :users, through: :user_roles, dependent: :delete_all
end
