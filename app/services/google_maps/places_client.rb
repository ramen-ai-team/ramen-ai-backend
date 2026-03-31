require "net/http"
require "json"

module GoogleMaps
  class PlacesClient
    PLACES_API_URL = "https://maps.googleapis.com/maps/api/place/details/json"

    def self.fetch_place_details(place_id)
      api_key = ENV["GOOGLE_MAPS_API_KEY"]

      if api_key.blank?
        Rails.logger.error("Google Maps API key is not configured")
        return nil
      end

      uri = URI(PLACES_API_URL)
      params = {
        place_id: place_id,
        key: api_key,
        fields: "name,formatted_address,formatted_phone_number,geometry",
        language: "ja"
      }
      uri.query = URI.encode_www_form(params)

      response = Net::HTTP.get_response(uri)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Places API HTTP error: #{response.code} #{response.message}")
        return nil
      end

      data = JSON.parse(response.body, symbolize_names: true)
      unless data[:status] == "OK"
        Rails.logger.error("Places API status error: #{data[:status]} - #{data[:error_message]}")
        return nil
      end

      result = data[:result]
      {
        name: result[:name],
        address: result[:formatted_address],
        phone_number: result[:formatted_phone_number],
        latitude: result.dig(:geometry, :location, :lat),
        longitude: result.dig(:geometry, :location, :lng)
      }
    rescue StandardError => e
      Rails.logger.error("Failed to fetch place details: #{e.message}")
      nil
    end
  end
end
