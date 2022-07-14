FactoryBot.define do
  factory :permission_request do
    status { 'in_progress' }
    establishment_id { 0 }
    other_establishment { 'Hospital Dr. Ramon Carrillo' }
    sector_id { 0 }
    other_sector { 'Farmacia' }

    trait :req_1 do
      association :user, factory: :user_6
    end

    factory :permission_req_1, traits: %i[req_1]
  end
end
