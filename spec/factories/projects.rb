FactoryBot.define do
  factory :project do
    title { "Project title" }
    description { "Some project description that is long enough!" }
    coordinators { [ association(:user) ] }

    trait :published do
      published_at { Time.zone.now }
    end

    trait :not_published do
      published_at { nil }
    end

    trait :with_published_tasks do
      transient do
        tasks_count { 3 }
      end

      tasks do
        Array.new(tasks_count) { association :task, :published }
      end
    end

    trait :without_coordinators do
      coordinators { [] }
    end
  end
end
