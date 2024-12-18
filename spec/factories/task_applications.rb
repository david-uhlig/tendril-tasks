FactoryBot.define do
  factory :task_application do
    association :task, :published, :with_published_project
    association :user
    comment { "Just a comment" }
    status { :received }

    trait :withdrawn do
      association :status, :withdrawn
    end

    trait :grace_period_expired do
      created_at { (TaskApplication::GRACE_PERIOD + 1.second).ago }
    end
  end
end
