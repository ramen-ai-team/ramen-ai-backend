class Api::V1::Admin::ApplicationController < ApplicationController
  include JsonWebToken

  before_action :authenticate_admin_request

  private

  def authenticate_admin_request
    header = request.headers["Authorization"]
    header = header.split(" ").last if header

    begin
      decoded = jwt_decode(header)
      @current_admin_user = AdminUser.find(decoded[:admin_user_id])
    rescue JWT::DecodeError
      render json: { error: "Unauthorized" }, status: :unauthorized
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Admin user not found" }, status: :unauthorized
    end
  end

  def current_admin_user
    @current_admin_user
  end
end