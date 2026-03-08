module JsonWebToken
  extend ActiveSupport::Concern

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: "HS256" })[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::ExpiredSignature
    raise JWT::DecodeError, "Token has expired"
  end
end
