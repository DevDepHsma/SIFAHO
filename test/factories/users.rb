FactoryBot.define do
  factory :user do
    username { 12345678 }
    password { 'password' }
    status { 'active' }

    trait :u_1 do
      username { 000055555 }
      password { 'password' }
      status { 'permission_req' }
    end

    factory :user_1, traits: %i[u_1]
  end
end
