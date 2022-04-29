FactoryBot.define do
  factory :user do
    username { 12345678 }
    password { 'password' }

    trait :test_1 do
      username { 00001111 }
      password { 'password' }
    end

    trait :u_1 do
      username { 00002222 }
      password { 'password' }
      association :sector, factory: :sector_1
    end

    trait :u_2 do
      username { 00003333 }
      password { 'password' }
      association :sector, factory: :sector_1
    end

    trait :current_sector do
      association :sector, factory: :informatica_sector
    end

    factory :simple_user, traits: %i[test_1]
    factory :it_user, traits: %i[test_1 current_sector]
    factory :user_1, traits: %i[u_1]
    factory :user_2, traits: %i[u_2]
  end
end
