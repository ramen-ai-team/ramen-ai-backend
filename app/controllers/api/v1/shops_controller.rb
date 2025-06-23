module Api
  module V1
    class ShopsController < BaseController
      before_action :set_shop, only: [:show]

      def index
        pagy, shops = pagy(Shop.all)
        shop_list = ApiEntity::ShopList.new(shops:)
        pagy_headers_merge(pagy)
        render json: shop_list, status: :ok
      end

      def show
        render json: ApiEntity::Shop.new(shop: @shop), status: :ok
      end

      private

      def set_shop
        @shop = Shop.find(params[:id])
      end
    end
  end
end
