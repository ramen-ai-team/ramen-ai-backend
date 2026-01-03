module Api
  module V1
    class ShopsController < BaseController
      before_action :set_shop, only: [:show]
      skip_before_action :authenticate_user, only: [:index, :show]

      def index
        pagy, shops = pagy(Shop.all)
        shop_list = ApiEntity::ShopList.new(shops:)
        pagy_headers_merge(pagy)
        render json: shop_list, status: :ok
      end

      def show
        render json: ApiEntity::Shop.new(shop: @shop), status: :ok
      end

      def create
        google_map_url = params[:google_map_url]

        place_id = GoogleMaps::PlaceIdExtractor.extract(google_map_url)
        if place_id.nil?
          render json: { error: "Invalid Google Maps URL" }, status: :bad_request
          return
        end

        place_details = GoogleMaps::PlacesClient.fetch_place_details(place_id)
        if place_details.nil?
          render json: { error: "Failed to fetch place details from Google Maps" }, status: :service_unavailable
          return
        end

        shop = Shop.create!(
          name: place_details[:name],
          address: place_details[:address],
          google_map_url: google_map_url
        )

        render json: ApiEntity::Shop.new(shop: shop), status: :created
      end

      private

      def set_shop
        @shop = Shop.find(params[:id])
      end
    end
  end
end
