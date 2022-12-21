FactoryBot.define do
  factory :establishment do
    name { 'Dr. Juan Hospital' }
    short_name { 'DJH' }
    establishment_type
    sanitary_zone

    trait :hospital_type do
      association :establishment_type, factory: :hospital_establishment_type
    end

    trait :iv_zone do
      association :sanitary_zone, factory: :iv_sanitary_zone
    end

    trait :est_1 do
      name { 'Hospital Dr. Ramón Carrillo' }
      short_name { 'HSMA' }
      cuie{'658999'}
    end

    trait :est_2 do
      name { 'Hospital Junin de los andes' }
      short_name { 'HJA' }
      cuie{'968217'}
    end

    trait :est_3 do
      name { 'Hospital Zapala' }
      short_name { 'HZ' }
      cuie{'123612'}
    end

    factory :establishment_1, traits: %i[hospital_type iv_zone est_1]
    factory :establishment_2, traits: %i[hospital_type iv_zone est_2]
    factory :establishment_3, traits: %i[hospital_type iv_zone est_3]
    
  end
end
