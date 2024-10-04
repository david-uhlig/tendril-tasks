FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:uid) { |n| "uid#{n}" }

  factory :user do
    email
    password { "password" }
    provider { "rocketchat" }
    uid
  end
end
