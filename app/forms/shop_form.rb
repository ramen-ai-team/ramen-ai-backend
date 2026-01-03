class ShopForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :google_map_url, :string

  validates :google_map_url, presence: { message: "を入力してください" }
  validates :google_map_url, google_maps_url: true

  def save
    return false unless valid?

    place_id = GoogleMaps::PlaceIdExtractor.extract(google_map_url)
    if place_id.nil?
      errors.add(:google_map_url, "から店舗情報を取得できませんでした")
      return false
    end

    place_details = GoogleMaps::PlacesClient.fetch_place_details(place_id)
    if place_details.nil?
      errors.add(:google_map_url, "から店舗情報を取得できませんでした")
      return false
    end

    shop = Shop.create(
      name: place_details[:name],
      address: place_details[:address],
      google_map_url: google_map_url
    )

    shop.persisted? ? shop : false
  rescue StandardError => e
    Rails.logger.error("Failed to create shop: #{e.message}")
    errors.add(:base, "店舗の作成に失敗しました")
    false
  end
end
