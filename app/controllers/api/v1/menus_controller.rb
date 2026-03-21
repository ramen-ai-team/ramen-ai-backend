module Api
  module V1
    class MenusController < BaseController
      skip_before_action :authenticate_user, only: [:index]

      def index
        shop = Shop.find(params[:shop_id])
        render json: ApiEntity::MenuWithShopList.new(menus: shop.menus).to_json
      end
    end
  end
end
