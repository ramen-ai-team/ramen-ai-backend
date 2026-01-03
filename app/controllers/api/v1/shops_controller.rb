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
        form = ShopForm.new(google_map_url: params[:google_map_url])

        if form.valid?
          shop = form.save
          if shop
            render json: ApiEntity::Shop.new(shop: shop), status: :created
          else
            render json: { errors: form.errors.full_messages }, status: :service_unavailable
          end
        else
          render json: { errors: form.errors.full_messages }, status: :bad_request
        end
      end

      private

      def set_shop
        @shop = Shop.find(params[:id])
      end
    end
  end
end
