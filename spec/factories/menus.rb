FactoryBot.define do
  factory :menu do
    association :shop

    sequence(:name) { |n| "Ramen #{n}" }

    trait :with_category do
      transient do
        genre { nil }
        noodle { nil }
        soup { nil }
      end

      after(:create) do |menu, evaluator|
        create(:menu_genre, menu: menu, genre: evaluator.genre || create(:genre))
        create(:menu_noodle, menu: menu, noodle: evaluator.noodle || create(:noodle))
        create(:menu_soup, menu: menu, soup: evaluator.soup || create(:soup))
      end
    end
  end
end
