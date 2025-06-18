module Api
  module V1
    class RecommendedMenusController < BaseController
      def create
        select_menu_ids = params[:select_menu_ids]
        not_select_menu_ids = params[:not_select_menu_ids] || []
        if select_menu_ids.blank?
          render json: { error: "select_menu_idsが必要です" }, status: :bad_request
          return
        end

        select_menus = Menu.where(id: select_menu_ids)
        unselect_menus = Menu.where.not(id: not_select_menu_ids)
        begin
          request_text = GeminiApi.generate_request_text(select_menus, unselect_menus)
          recommended_menu = GeminiApi.generate_content(request_text)
          render json: { recommended_menu: recommended_menu }
        rescue => e
          render json: { error: e.message }, status: :internal_server_error
        end
      end
    end
  end
end
