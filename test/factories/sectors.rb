FactoryBot.define do
  factory :sector do
    name { 'Informática' }
    description { 'Lorem ipsum......' }
    establishment

    trait :sec_1 do
      name { 'Farmacia' }
    end

    trait :sec_2 do
      name { 'Depósito' }
    end
   

    factory :sector_1, traits: %i[sec_1]
    factory :sector_2, traits: %i[sec_2]
   
  end
end
