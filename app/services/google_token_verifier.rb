class GoogleTokenVerifier
  TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token"
  TOKENINFO_ENDPOINT = "https://www.googleapis.com/oauth2/v3/tokeninfo"

  def self.verify(code, redirect_uri)
    id_token = exchange_code(code, redirect_uri)
    return false unless id_token

    verify_id_token(id_token)
  rescue => e
    Rails.logger.error "Google token verification failed: #{e.message}"
    false
  end

  def self.exchange_code(code, redirect_uri)
    response = HTTParty.post(TOKEN_ENDPOINT, body: {
      code: code,
      client_id: Rails.application.credentials.gcp[:client_id],
      client_secret: Rails.application.credentials.gcp[:client_secret],
      redirect_uri: redirect_uri,
      grant_type: "authorization_code"
    })

    unless response.success?
      Rails.logger.error "Google code exchange failed: #{response.code} #{response.body}"
      return nil
    end

    response.parsed_response["id_token"]
  end

  def self.verify_id_token(id_token)
    response = HTTParty.get("#{TOKENINFO_ENDPOINT}?id_token=#{id_token}")

    return false unless response.success?

    token_data = response.parsed_response

    return false unless token_data["aud"] == Rails.application.credentials.gcp[:client_id]
    return false unless ["https://accounts.google.com", "accounts.google.com"].include?(token_data["iss"])
    return false unless token_data["exp"].to_i > Time.current.to_i

    {
      google_id: token_data["sub"],
      email: token_data["email"],
      name: token_data["name"],
      picture: token_data["picture"],
      email_verified: token_data["email_verified"] == "true"
    }
  end
end
