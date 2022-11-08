require 'support/data_mock/mock'
require 'support/db_populate/effectors'
require 'support/db_populate/users'
require 'support/db_populate/permissions'
require 'support/db_populate/products'
require 'support/db_populate/stocks'
require 'support/db_populate/roles'
require 'support/db_populate/patients'
require 'support/db_populate/reports'

RSpec.configure do |config|
  config.include DataMock::Products, type: :feature
  config.include DataMock::Permissions, type: :feature
  config.include DataMock::Roles, type: :feature
  config.include DataMock::Patients, type: :feature
  config.include DataMock::Professionals, type: :feature
  config.include DataMock::Reports, type: :feature
  config.include DataMock::Users, type: :feature

  config.before(:all, type: :feature) do
    permissions_populate
    effectors_populate
    products_populate
    stocks_populate
    roles_populate
    users_populate
    patients_populate
    professionals_populate
    outpatient_prescriptions_populate
    chronic_prescriptions_populate
    reports_populate
  end
end
