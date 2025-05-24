FactoryBot.define do
  factory :menu do
    association :shop

    sequence(:name) { |n| "Ramen #{n}" }

    trait :with_genre do
      transient do
        genre { nil }
      end

      after(:create) do |menu, evaluator|
        create(:menu_genre, menu: menu, genre: evaluator.genre || create(:genre))
      end
    end

    trait :with_noodle do
      transient do
        noodle { nil }
      end

      after(:create) do |menu, evaluator|
        create(:menu_noodle, menu: menu, noodle: evaluator.noodle || create(:noodle))
      end
    end

    trait :with_soup do
      transient do
        soup { nil }
      end

      after(:create) do |menu, evaluator|
        create(:menu_soup, menu: menu, soup: evaluator.soup || create(:soup))
      end
    end
  end
end
