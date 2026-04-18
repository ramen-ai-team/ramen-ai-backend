require "net/http"
require "json"

module GoogleMaps
  class PlacesClient
    PLACES_API_BASE_URL = "https://places.googleapis.com/v1/places"
    FIELD_MASK = "displayName,formattedAddress,nationalPhoneNumber,location"

    def self.fetch_place_details(place_id)
      api_key = ENV["GOOGLE_MAPS_API_KEY"]

      if api_key.blank?
        Rails.logger.error("Google Maps API key is not configured")
        return nil
      end

      uri = URI("#{PLACES_API_BASE_URL}/#{place_id}")
      uri.query = URI.encode_www_form(languageCode: "ja")

      request = Net::HTTP::Get.new(uri)
      request["X-Goog-Api-Key"] = api_key
      request["X-Goog-FieldMask"] = FIELD_MASK

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error("Places API HTTP error: #{response.code} #{response.message} - #{response.body}")
        return nil
      end

      data = JSON.parse(response.body, symbolize_names: true)
      if data[:error]
        Rails.logger.error("Places API error: #{data.dig(:error, :status)} - #{data.dig(:error, :message)}")
        return nil
      end

      {
        name: data.dig(:displayName, :text),
        address: data[:formattedAddress],
        phone_number: data[:nationalPhoneNumber],
        latitude: data.dig(:location, :latitude),
        longitude: data.dig(:location, :longitude)
      }
    rescue StandardError => e
      Rails.logger.error("Failed to fetch place details: #{e.message}")
      nil
    end
  end
end
