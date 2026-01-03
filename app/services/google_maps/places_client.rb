require "net/http"
require "json"

module GoogleMaps
  class PlacesClient
    PLACES_API_URL = "https://maps.googleapis.com/maps/api/place/details/json"

    def self.fetch_place_details(place_id)
      api_key = Rails.application.credentials.google_maps_api_key

      if api_key.blank?
        Rails.logger.error("Google Maps API key is not configured")
        return nil
      end

      uri = URI(PLACES_API_URL)
      params = {
        place_id: place_id,
        key: api_key,
        fields: "name,formatted_address,formatted_phone_number",
        language: "ja"
      }
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body, symbolize_names: true)
      return nil unless data[:status] == "OK"

      result = data[:result]
      {
        name: result[:name],
        address: result[:formatted_address],
        phone_number: result[:formatted_phone_number]
      }
    rescue StandardError => e
      Rails.logger.error("Failed to fetch place details: #{e.message}")
      nil
    end
  end
end
