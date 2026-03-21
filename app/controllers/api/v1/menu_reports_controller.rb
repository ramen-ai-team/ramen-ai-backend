module Api
  module V1
    class MenuReportsController < BaseController
      def create
        menu_report = MenuReportCreationService.new(user: current_user, params: params).call
        render json: ApiEntity::MenuReport.new(menu_report:).to_json, status: :created
      rescue ArgumentError, ActiveRecord::RecordInvalid => e
        render json: ApiEntity::Errors.new(e.message).to_json, status: :unprocessable_entity
      end
    end
  end
end
