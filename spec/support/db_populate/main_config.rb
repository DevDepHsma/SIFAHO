require 'support/data_mock/mock'
require 'support/db_populate/effectors'
require 'support/db_populate/users'
require 'support/db_populate/permissions'
require 'support/db_populate/products'
require 'support/db_populate/stocks'
require 'support/db_populate/roles'

RSpec.configure do |config|
  config.include DataMock::Products, type: :feature
  config.include DataMock::Permissions, type: :feature
  config.include DataMock::Roles, type: :feature

  config.before(:all, type: :feature) do
    permissions_populate
    effectors_populate
    users_populate
    products_populate
    stocks_populate
    roles_populate
  end
end