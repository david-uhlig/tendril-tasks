FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:uid) { |n| "uid#{n}" }

  factory :user do
    email
    password { "password" }
    provider { "rocketchat" }
    uid
    name { "John Smith" }
    username { "john.smith" }
    avatar_url { "https://example.com/john_smith.svg" }
  end
end
