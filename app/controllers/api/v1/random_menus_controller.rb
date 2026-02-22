module Api
  module V1
    class RandomMenusController < BaseController
      skip_before_action :authenticate_user, only: [:index]

      def index
        menus = Menu.includes(:genre, :noodle, :soup).with_attached_image.order("RANDOM()").limit(params[:limit] || 10)
        menu_list = ApiEntity::MenuList.new(menus:)
        render json: menu_list, status: :ok
      end
    end
  end
end
