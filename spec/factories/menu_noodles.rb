FactoryBot.define do
  factory :menu_noodle do
    menu { association :menu }
    noodle { association :noodle }
  end
end
