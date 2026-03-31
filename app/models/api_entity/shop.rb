module ApiEntity
  class Shop
    include ::ActiveModel::Serializers::JSON

    delegate :id, :name, :address, :google_map_url, :latitude, :longitude, to: :@shop

    def initialize(shop:)
      @shop = shop
    end

    private

    def attribute_names_for_serialization = %i[id name address google_map_url latitude longitude]
  end
end
