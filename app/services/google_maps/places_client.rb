require "net/http"
require "json"

module GoogleMaps
  class PlacesClient
    SEARCH_TEXT_URL = "https://places.googleapis.com/v1/places:searchText"
    FIELD_MASK = "places.displayName,places.formattedAddress,places.nationalPhoneNumber,places.location"

    def self.fetch_place_details(search_info)
      api_key = ENV["GOOGLE_MAPS_API_KEY"]

      if api_key.blank?
        Rails.logger.error("Google Maps API key is not configured")
        return nil
      end

      uri = URI(SEARCH_TEXT_URL)

      request = Net::HTTP::Post.new(uri)
      request["X-Goog-Api-Key"] = api_key
      request["X-Goog-FieldMask"] = FIELD_MASK
      request["Content-Type"] = "application/json"
      request.body = {
        textQuery: search_info[:name],
        locationBias: {
          circle: {
            center: {
              latitude: search_info[:latitude],
              longitude: search_info[:longitude]
            },
            radius: 50.0
          }
        },
        languageCode: "ja"
      }.to_json

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

      place = data.dig(:places, 0)
      if place.nil?
        Rails.logger.error("Places API: no results found for #{search_info[:name]}")
        return nil
      end

      {
        name: place.dig(:displayName, :text),
        address: place[:formattedAddress],
        phone_number: place[:nationalPhoneNumber],
        latitude: place.dig(:location, :latitude),
        longitude: place.dig(:location, :longitude)
      }
    rescue StandardError => e
      Rails.logger.error("Failed to fetch place details: #{e.message}")
      nil
    end
  end
end
