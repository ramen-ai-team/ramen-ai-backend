module Api
  module V1
    class BaseController < ::ApplicationController
      include Pagy::Backend
      include JsonWebToken

      rescue_from ActiveRecord::RecordNotFound do |exception|
        render json: { error: exception.message }, status: :not_found
      end

      before_action :authenticate_user

      private

      def authenticate_user
        header = request.headers["Authorization"]
        header = header.split(" ").last if header

        if header.blank?
          render json: { error: "Authorization header missing" }, status: :unauthorized
          return
        end

        begin
          decoded = jwt_decode(header)
          @current_user = User.find(decoded[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          render json: { error: "User not found" }, status: :unauthorized
        rescue JWT::DecodeError => e
          render json: { error: "Invalid token" }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
