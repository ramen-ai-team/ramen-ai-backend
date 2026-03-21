FactoryBot.define do
  factory :menu_report do
    association :user
    association :menu
    association :genre
    association :noodle
    association :soup
  end
end
