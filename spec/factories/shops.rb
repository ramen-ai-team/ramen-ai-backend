FactoryBot.define do
  factory :shop do
    sequence(:name) { |n| "Shop #{n}" }
    address { |n| "東京都新宿区 #{n}" }
    google_map_url { |n| "https://maps.app.goo.gl/#{n}" }
  end
end
