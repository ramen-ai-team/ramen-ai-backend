class Api::V1::SessionsController < Api::V1::BaseController
  include JsonWebToken

  skip_before_action :authenticate_user, only: [:google_auth]

  def google_auth
    token = params[:token]
    if token.blank?
      render json: { error: "Invalid token" }, status: :unauthorized
      return
    end

    begin
      # todo: tokenを検証する
      user_info = {
        "sub" => "123456789",
        "email" => "user@example.com",
        "name" => "John Doe",
        "picture" => "https://lh3.googleusercontent.com/a/default-user"
      }

      # Create or find user
      user = User.find_or_create_by!(
        email: user_info["email"],
        provider: "google"
      ) do |u|
        u.name = user_info["name"]
        u.uid = user_info["sub"]
        u.image = user_info["picture"]
      end

      if user.persisted?
        jwt_token = jwt_encode(user_id: user.id)
        render json: {
          token: jwt_token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            image: user.image
          }
        }, status: :ok
      else
        render json: { error: "Failed to create user" }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: "Authentication failed" }, status: :unauthorized
    end
  end
end
