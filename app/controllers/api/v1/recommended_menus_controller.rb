module Api
  module V1
    class RecommendedMenusController < BaseController
      skip_before_action :authenticate_user, only: [:create]

      def create
        select_menu_ids = params[:select_menu_ids]
        not_select_menu_ids = params[:not_select_menu_ids] || []
        if select_menu_ids.blank?
          render json: { error: "select_menu_idsが必要です" }, status: :bad_request
          return
        end

        select_menus = Menu.includes(:soup, :genre, :noodle).where(id: select_menu_ids)
        unselect_menus = Menu.includes(:soup, :genre, :noodle).where.not(id: not_select_menu_ids)
          # begin
          request_text = GeminiApi.generate_request_text(select_menus, unselect_menus)
          response = GeminiApi.generate_content(request_text)
          recommended_menu = RecommendedMenu.new(response["recommended_ramen"]).find_best_match
          reason = response["reason"] || "おすすめの理由がありません"
          render json: { recommended_menu: ApiEntity::MenuWithShop.new(menu: recommended_menu), reason: }
        # rescue => e
        #   render json: { error: e.message }, status: :internal_server_error
        # end
      end
    end
  end
end
