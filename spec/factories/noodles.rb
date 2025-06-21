FactoryBot.define do
  factory :noodle do
    sequence(:name) { |n| "Noodle #{n}" }
  end
end
