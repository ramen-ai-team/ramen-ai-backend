module Api
  module V1
    class RandomMenusController < BaseController
      def index
        menus = Menu.order("RAND()").limit(params[:limit] || 10)
        menu_list = ApiEntity::MenuList.new(menus:)
        render json: menu_list, status: :ok
      end
    end
  end
end
