require "net/http"
require "uri"
require "json"

class GeminiApi
  LOCATION = "us-central1".freeze

  def self.generate_request_text(menus)
    <<~TEXT
      以下はある人が選択したラーメンの嗜好です。これを踏まえて、最もおすすめのラーメンを教えて下さい
      #{menus.map { |menu| "- ジャンル：#{menu.genre.name}、麺：#{menu.noodle.name}、味：#{menu.soup.name}" }.join("\n")}
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
    access_token = "" # gcloud auth print-access-token
    project_id = "ramen-ai"
    model_id = "gemini-2.5-flash-preview-05-20"
    uri = URI.parse("https://#{LOCATION}-aiplatform.googleapis.com/v1/projects/#{project_id}/locations/#{LOCATION}/publishers/google/models/#{model_id}:streamGenerateContent")
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
                "genre": { "type": "STRING", "enum": Genre.pluck(:name) },
                "noodles": { "type": "STRING", "enum": Noodle.pluck(:name) },
                "soups": { "type": "STRING", "enum": Soup.pluck(:name) }
              },
              "required": ["genre", "noodles", "soups"]
            },
            "reason": {
              "type": "STRING",
              "description": "250文字以内でそのラーメンをおすすめする理由を記載してください"
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
