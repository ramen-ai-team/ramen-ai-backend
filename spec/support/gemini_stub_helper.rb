module GeminiStubHelper
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
      url: 'https://aiplatform.googleapis.com/v1/projects/ramen-ai/locations/global/publishers/google/models/gemini-2.5-pro-preview-06-05:streamGenerateContent',
      file: 'recommended_ramen.json',
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
