FactoryBot.define do
  factory :review do
    association :menu
    association :user
    rating { rand(1..5) }
    comment { "おいしかった" }
    visited_at { Date.today }
  end
end
