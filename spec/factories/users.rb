FactoryBot.define do
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:uid) { |n| "uid#{n}" }
  sequence(:session_token) { |n| SecureRandom.hex }

  factory :user do
    email
    password { "password" }
    provider { "rocketchat" }
    uid
    name { "John Smith" }
    username { "john.smith" }
    avatar_url { "https://example.com/john_smith.svg" }
    role { :user }
    session_token

    trait :admin do
      role { :admin }
    end

    trait :editor do
      role { :editor }
    end
  end
end
