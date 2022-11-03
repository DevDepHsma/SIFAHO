# == Schema Information

# Table name: permissions

# id                      :bigint   not null, primary key
# name                    :string   not null
# permission_module_id    :bigint   not null
#

class Permission < ApplicationRecord
  belongs_to :permission_module, optional: false
  has_many :permission_users, dependent: :delete_all

  validates_presence_of :name
end
