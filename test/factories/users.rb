FactoryBot.define do
  factory :user do
    username { 12345678 }
    password { 'password' }

    trait :u_1 do
      username { 00002222 }
      password { 'password' }
      association :sector, factory: :sector_1
      status { 'active' }
    end

    trait :u_2 do
      username { 00003333 }
      password { 'password' }
      association :sector, factory: :sector_1
      status { 'active' }
    end

    trait :u_3 do
      username { 00004444 }
      password { 'password' }
      association :sector, factory: :sector_1
      status { 'active' }
    end

    trait :u_4 do
      username { 000055555 }
      password { 'password' }
      association :sector, factory: :sector_1
      status { 'active' }
    end

    trait :u_5 do
      username { 00006666 }
      password { 'password' }
    end

    factory :user_1, traits: %i[u_1]
    factory :user_2, traits: %i[u_2]
    factory :user_3, traits: %i[u_3]
    factory :user_4, traits: %i[u_4]
    factory :user_5, traits: %i[u_5]
  end
end
