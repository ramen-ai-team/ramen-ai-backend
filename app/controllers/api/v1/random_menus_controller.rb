module Api
  module V1
    class RandomMenusController < BaseController
      def index
        menus = Menu.includes(:genre, :noodle, :soup).order("RAND()").limit(params[:limit] || 10)
        menu_list = ApiEntity::MenuList.new(menus:)
        render json: menu_list, status: :ok
      end
    end
  end
end
