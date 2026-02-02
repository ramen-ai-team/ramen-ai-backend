module AuthHelper
  def auth_headers_for(user)
    token = jwt_encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  def admin_auth_headers_for(admin_user)
    token = jwt_encode(admin_user_id: admin_user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    secret_key = Rails.application.credentials.secret_key_base || "your-secret-key"
    JWT.encode(payload, secret_key)
  end
end
