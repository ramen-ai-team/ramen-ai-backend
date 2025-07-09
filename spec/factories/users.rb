FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name) { |n| "User #{n}" }
    provider { "google" }
    uid { SecureRandom.uuid }
    image { "https://example.com/user_image.png" }
  end
end
