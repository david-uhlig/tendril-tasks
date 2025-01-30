FactoryBot.define do
  factory :page do
    sequence(:slug) { |n| "page-slug-#{n}" }
    content { "Sample content" }
  end
end
