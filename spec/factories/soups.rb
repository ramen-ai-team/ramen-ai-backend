FactoryBot.define do
  factory :soup do
    sequence(:name) { |n| "Soup #{n}" }
  end
end
