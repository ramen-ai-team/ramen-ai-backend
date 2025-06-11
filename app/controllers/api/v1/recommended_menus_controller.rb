module Api
  module V1
    class RecommendedMenusController < BaseController
      def create
        menu_ids = params[:menu_ids]
        if menu_ids.blank?
          render json: { error: "menu_idsが必要です" }, status: :bad_request
          return
        end

        begin
          menus = Menu.where(id: menu_ids)
          request_text = GeminiApi.generate_request_text(menus)
          recommended_menu = GeminiApi.generate_content(request_text)
          render json: { recommended_menu: recommended_menu }
        rescue => e
          render json: { error: e.message }, status: :internal_server_error
        end
      end
    end
  end
end
