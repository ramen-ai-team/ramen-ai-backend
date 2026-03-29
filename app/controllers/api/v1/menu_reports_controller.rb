module Api
  module V1
    class MenuReportsController < BaseController
      skip_before_action :authenticate_user, only: [:show]

      def show
        menu_report = MenuReport.find(params[:id])
        render json: ApiEntity::MenuReport.new(menu_report:).to_json, status: :ok
      end

      def create
        menu_report = MenuReportCreationService.new(user: current_user, params: params).call
        render json: ApiEntity::MenuReport.new(menu_report:).to_json, status: :created
      rescue ArgumentError, ActiveRecord::RecordInvalid => e
        render json: ApiEntity::Errors.new(e.message).to_json, status: :unprocessable_entity
      end

      def destroy
        menu_report = current_user.menu_reports.find(params[:id])
        menu_report.destroy!
        head :no_content
      end
    end
  end
end
