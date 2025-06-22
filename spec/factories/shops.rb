FactoryBot.define do
  factory :shop do
    sequence(:name) { |n| "Shop #{n}" }
    address { FFaker::Address.street_address }
    google_map_url { |n| "#{FFaker::Internet.http_url}#{n}" }
  end
end
