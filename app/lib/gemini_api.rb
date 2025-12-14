require "net/http"
require "uri"
require "json"

class GeminiApi
  LOCATION = "global".freeze
  API_ENDPOINT = "aiplatform.googleapis.com".freeze
  GENERATE_CONTENT_API = "streamGenerateContent".freeze

  def self.credential
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      scope: "https://www.googleapis.com/auth/cloud-platform"
    )
    authorizer.fetch_access_token!
  end

  def self.generate_request_text(select_menus, not_select_menus)
    text = <<~TEXT
      以下はある人が選択したラーメンの嗜好です。これを踏まえて、最もおすすめのラーメンを教えて下さい
      ## 選択されたラーメン
      #{select_menus.map { |menu| "- 名前：#{menu.name} ジャンル：#{menu.genre.name}、麺：#{menu.noodle.name}、味：#{menu.soup.name}" }.join("\n")}
    TEXT
    return text if not_select_menus.empty?

    text + <<~TEXT
      ## 選択されなかったラーメン
      #{not_select_menus.map { |menu| "- 名前：#{menu.name} ジャンル：#{menu.genre.name}、麺：#{menu.noodle.name}、味：#{menu.soup.name}" }.join("\n")}
    TEXT
  end

  def self.generate_content(text)
    raise ArgumentError, "Text must be provided" if text.nil? || text.strip.empty?

    response = call(text)
    if response.is_a?(Hash) && response["error"]
      Rails.logger.error("Gemini API Error: #{response['error']['message']}")
      return
    end

    response_text = response.map do |part|
      part["candidates"].map do |candidate|
        candidate["content"]["parts"].map do |content_part|
          content_part["text"]
        end
      end.flatten
    end.flatten.join
    JSON.parse(response_text)
  end

  private

  def self.call(text)
    access_token = credential["access_token"]
    project_id = "ramen-ai"
    model_id = "gemini-2.5-flash"  # 最新の安定版
    uri = URI.parse("https://#{API_ENDPOINT}/v1/projects/#{project_id}/locations/#{LOCATION}/publishers/google/models/#{model_id}:#{GENERATE_CONTENT_API}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Authorization"] = "Bearer #{access_token}"
    request["Content-Type"] = "application/json"
    request.body = {
      "contents": {
        "role": "user",
        "parts": [
          {
            "text": text
          }
        ]
      },
      "generationConfig": {
        "responseMimeType": "application/json",
        "responseSchema": {
          "type": "OBJECT",
          "properties": {
            "recommended_ramen": {
              "type": "OBJECT",
              "properties": {
                "genre": { "type": "STRING", "enum": Genre.pluck(:name), description: "ジャンル" },
                "noodles": { "type": "STRING", "enum": Noodle.pluck(:name), description: "麺" },
                "soups": { "type": "STRING", "enum": Soup.pluck(:name), description: "スープ（味）" }
              },
              "required": ["genre", "noodles", "soups"]
            },
            "reason": {
              "type": "STRING",
              "description": "250文字以内でそのラーメンをおすすめする理由を記載してください。ただし、根拠として選択に関する情報を含めないでください。"
            }
          },
          "propertyOrdering": ["recommended_ramen", "reason"]
        }
      }
    }.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end
end
