FactoryBot.define do
  factory :patient do
    first_name { 'test' }
    last_name { 'test' }
    dni { '1111111' }
    sex { 'otro' }
    marital_status { 'soltero' }
  end
end
