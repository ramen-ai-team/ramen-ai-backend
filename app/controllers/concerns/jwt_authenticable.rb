module JwtAuthenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_jwt_token!, unless: :skip_authentication?
  end

  private

  def authenticate_jwt_token!
    token = extract_token_from_header

    if token.nil?
      render json: ApiEntity::Errors.new("missing_token").to_json, status: :unauthorized
      return
    end

    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })
      @current_user = User.find(decoded_token[0]["user_id"])
    rescue JWT::ExpiredSignature
      render json: ApiEntity::Errors.new("expired_token").to_json, status: :unauthorized
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: ApiEntity::Errors.new("invalid_token").to_json, status: :unauthorized
    end
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    header&.split(" ")&.last if header&.starts_with?("Bearer ")
  end

  def current_user
    @current_user
  end

  def skip_authentication?
    false
  end
end
