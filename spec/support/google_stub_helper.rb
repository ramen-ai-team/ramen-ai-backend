module GoogleStubHelper
  def stub_gemini_token
    allow(GeminiApi).to receive(:credential).and_return({ 'access_token' => 'test_access_token' })
  end

  def stub_gemini_recommended_ramen
    stub_gemini_api(
      method: :post,
      url: 'https://aiplatform.googleapis.com/v1/projects/ramen-ai/locations/global/publishers/google/models/gemini-2.5-flash:streamGenerateContent',
      file: 'recommended_ramen.json',
    )
  end

  def stub_google_code_exchange(code: 'valid_code', redirect_uri: 'https://example.com/callback', id_token: 'valid_id_token', status: 200)
    stub_request(:post, "https://oauth2.googleapis.com/token")
      .with(body: hash_including("code" => code, "redirect_uri" => redirect_uri))
      .to_return(
        status:,
        body: status == 200 ? { id_token: id_token, access_token: 'access_token', token_type: 'Bearer' }.to_json : { error: 'invalid_grant' }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
  end

  def stub_google_token_verifier(id_token: 'valid_id_token', status: 200, response_body: nil)
    url = "https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{id_token}"

    stub_request(:get, url)
      .to_return(
        status:,
        body: response_body || {
          sub: '123456789',
          email: 'user@example.com',
          name: 'John Doe',
          picture: 'https://lh3.googleusercontent.com/a/default-user',
          email_verified: 'true',
          aud: ENV["GCP_CLIENT_ID"],
          iss: 'https://accounts.google.com',
          exp: (Time.current + 1.hour).to_i
        }.to_json,
        headers: { 'Content-Type': 'application/json' }
      )
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
