FactoryBot.define do
  factory :menu_genre do
    menu { association :menu }
    genre { association :genre }
  end
end
