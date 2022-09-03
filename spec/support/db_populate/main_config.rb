require 'support/data_mock/mock'
require 'support/db_populate/effectors'
require 'support/db_populate/users'
require 'support/db_populate/permissions'
require 'support/db_populate/products'
require 'support/db_populate/stocks'
require 'support/db_populate/roles'
require 'support/db_populate/patients'
require 'support/db_populate/professionals'

RSpec.configure do |config|
  config.include DataMock::Products, type: :feature
  config.include DataMock::Permissions, type: :feature
  config.include DataMock::Roles, type: :feature
  config.include DataMock::Patients, type: :feature
  config.include DataMock::Professionals, type: :feature

  config.before(:all, type: :feature) do
    permissions_populate
    effectors_populate
    users_populate
    products_populate
    stocks_populate
    roles_populate
    patients_populate
    professionals_populate
  end
end
