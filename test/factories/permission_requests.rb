FactoryBot.define do
  factory :permission_request do
    status { 'in_progress' }
    establishment_id { 0 }
    other_establishment { 'Hospital Dr. Ramon Carrillo' }
    sector_id { 0 }
    other_sector { 'Farmacia' }
  end
end
