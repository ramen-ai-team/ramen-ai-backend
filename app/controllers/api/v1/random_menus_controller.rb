module Api
  module V1
    class RandomMenusController < BaseController
      def index
        pagy, menus = pagy(Menu.order("RAND()"))
        menu_list = ApiEntity::MenuList.new(menus:)
        pagy_headers_merge(pagy)
        render json: menu_list, status: :ok
      end
    end
  end
end
