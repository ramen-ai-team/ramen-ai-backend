class Api::V1::Admin::AuthenticationController < ApplicationController
  include JsonWebToken

  before_action :authenticate_admin_request, only: [:destroy]

  def create
    admin_user = AdminUser.find_by(email: params[:email])

    if admin_user&.valid_password?(params[:password])
      token = jwt_encode(admin_user_id: admin_user.id)
      render json: {
        token: token,
        admin_user: {
          id: admin_user.id,
          email: admin_user.email
        }
      }
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: "Logged out successfully" }
  end

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
end
