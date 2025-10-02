class GoogleTokenVerifier
  include HTTParty
  base_uri 'https://www.googleapis.com'

  def self.verify(id_token)
    response = get("/oauth2/v3/tokeninfo?id_token=#{id_token}")

    return nil unless response.success?

    token_data = response.parsed_response

    # 検証
    return nil unless token_data['aud'] == Rails.application.credentials.google[:client_id]
    return nil unless token_data['iss'] == 'https://accounts.google.com'
    return nil unless token_data['exp'].to_i > Time.current.to_i

    {
      google_id: token_data['sub'],
      email: token_data['email'],
      name: token_data['name'],
      picture: token_data['picture'],
      email_verified: token_data['email_verified'] == 'true'
    }
  rescue => e
    Rails.logger.error "Google token verification failed: #{e.message}"
    nil
  end
end