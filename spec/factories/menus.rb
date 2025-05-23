FactoryBot.define do
  factory :menu do
    association :shop

    sequence(:name) { |n| "Ramen #{n}" }
  end
end
