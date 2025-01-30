FactoryBot.define do
  factory :setting do
    sequence(:key) { |n| "setting_#{n}" }
    value { nil }

    trait :with_attachment do
      after(:build) do |setting|
        setting.attachments.attach(io: File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt')), filename: 'example.txt', content_type: 'text/plain')
      end
    end

    trait :with_attachments do
      transient do
        attachments_count { 3 }
      end

      after(:build) do |setting, evaluator|
        evaluator.attachments_count.times do
          setting.attachments.attach(io: File.open(Rails.root.join('spec', 'assets', 'files', 'example.txt')), filename: 'example.txt', content_type: 'text/plain')
        end
      end
    end
  end
end
