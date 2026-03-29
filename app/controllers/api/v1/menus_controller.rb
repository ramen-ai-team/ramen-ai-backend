module Api
  module V1
    class MenusController < BaseController
      skip_before_action :authenticate_user, only: [:index]

      def index
        shop = Shop.find(params[:shop_id])
        pagy, menus = pagy(shop.menus)
        pagy_headers_merge(pagy)
        render json: ApiEntity::MenuWithShopList.new(menus:).to_json
      end
    end
  end
end
