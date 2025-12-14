module GoogleStubHelper
  def stub_gemini_token
    stub_gemini_api(
      method: :post,
      url: 'https://www.googleapis.com/oauth2/v4/token',
      file: 'token.json',
    )
  end

  def stub_gemini_recommended_ramen
    stub_gemini_api(
      method: :post,
      url: 'https://aiplatform.googleapis.com/v1/projects/ramen-ai/locations/global/publishers/google/models/gemini-2.5-flash:streamGenerateContent',
      file: 'recommended_ramen.json',
    )
  end

  def stub_google_token_verifier(id_token: 'valid_token', success: true)
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"

    if success
      stub_request(:get, url)
        .to_return(
          status: 200,
          body: {
            sub: '123456789',
            email: 'user@example.com',
            name: 'John Doe',
            picture: 'https://lh3.googleusercontent.com/a/default-user',
            email_verified: 'true',
            aud: Rails.application.credentials.gcp[:client_id],
            iss: 'https://accounts.google.com',
            exp: (Time.current + 1.hour).to_i
          }.to_json,
          headers: { 'Content-Type': 'application/json' }
        )
    else
      stub_request(:get, url)
        .to_return(status: 401, body: {}.to_json)
    end
  end

  private

  def stub_gemini_api(method:, url:, options: {}, status: 200, file:)
    stub_request(method, url)
      .with(query: options)
      .to_return(
        status:,
        body: file_fixture("gemini/#{file}"),
        headers: { 'Content-Type': 'application/json' }
      )
  end
end
