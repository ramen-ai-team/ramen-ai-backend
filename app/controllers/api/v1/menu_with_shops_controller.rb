module Api
  module V1
    class MenuWithShopsController < BaseController
      before_action :set_menu, only: [:show]

      def show
        render json: ApiEntity::MenuWithShop.new(menu: @menu), status: :ok
      end

      private

      def set_menu
        @menu = Menu.find(params[:id])
      end
    end
  end
end
