module Api
  module V1
    module My
      class MenuReportsController < BaseController
        def index
          menu_reports = current_user.menu_reports
          render json: ApiEntity::MenuReportList.new(menu_reports:).to_json
        end
      end
    end
  end
end
