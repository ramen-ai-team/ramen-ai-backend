class Api::V1::Admin::AuthenticationController < ApplicationController
  include JsonWebToken

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
end
