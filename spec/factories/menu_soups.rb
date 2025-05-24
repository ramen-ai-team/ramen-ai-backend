FactoryBot.define do
  factory :menu_soup do
    menu { association :menu }
    soup { association :soup }
  end
end
