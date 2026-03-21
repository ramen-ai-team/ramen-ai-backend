module Api
  module V1
    class BaseController < ::ApplicationController
      include Pagy::Backend
      include JsonWebToken

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: ApiEntity::Errors.new(exception.message).to_json, status: :not_found
      end

      before_action :authenticate_user

      private

      def authenticate_user
        header = request.headers["Authorization"]
        header = header.split(" ").last if header

        if header.blank?
          render json: ApiEntity::Errors.new("missing_token").to_json, status: :unauthorized
          return
        end

        begin
          decoded = jwt_decode(header)
          @current_user = User.find(decoded[:user_id])
        rescue ActiveRecord::RecordNotFound
          render json: ApiEntity::Errors.new("user_not_found").to_json, status: :unauthorized
        rescue JWT::DecodeError
          render json: ApiEntity::Errors.new("invalid_token").to_json, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
