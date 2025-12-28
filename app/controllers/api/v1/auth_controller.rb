class Api::V1::AuthController < Api::V1::ApplicationController
  rescue_from StandardError, with: :handle_auth_error

  def google
    google_data = GoogleTokenVerifier.verify(params[:token])

    unless google_data
      render json: {
        error: "invalid_token",
        message: "Invalid or expired Google token"
      }, status: :unauthorized
      return
    end

    user = User.find_or_create_from_google(google_data)

    render json: {
      token: user.generate_jwt_token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        image: user.image
      }
    }
  end

  private

  def handle_auth_error(exception)
    Rails.logger.error "Auth error: #{exception.message}"
    render json: {
      error: "authentication_failed",
      message: "Authentication process failed"
    }, status: :internal_server_error
  end
end
