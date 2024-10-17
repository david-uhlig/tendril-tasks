FactoryBot.define do
  factory :task do
    title { "A default valid title" }
    description { "A default valid description" }
    association :project

    trait :published do
      published_at { Time.zone.now }
    end

    trait :not_published do
      published_at { nil }
    end

    trait :with_published_project do
      association :project, :published
    end

    trait :with_unpublished_project do
      association :project, :not_published
    end
  end
end
