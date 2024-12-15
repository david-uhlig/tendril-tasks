FactoryBot.define do
  factory :task_application do
    association :task, :published, :with_published_project
    association :user
    comment { "Just a comment" }
    status { :received }

    trait :withdrawn do
      association :status, :withdrawn
    end
  end
end
