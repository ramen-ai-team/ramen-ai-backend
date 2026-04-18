require "net/http"

module GoogleMaps
  class PlaceIdExtractor
    def self.extract(url)
      return nil if url.blank?

      target_url = url
      if url.include?("goo.gl")
        target_url = resolve_redirect(url)
        return nil if target_url.nil?
      end

      return nil unless target_url.include?("google.com/maps")

      coord_match = target_url.match(/@([-\d.]+),([-\d.]+)/)
      name_match = target_url.match(%r{/maps/place/([^/@]+)})

      return nil unless coord_match && name_match

      {
        name: URI.decode_www_form_component(name_match[1]),
        latitude: coord_match[1].to_f,
        longitude: coord_match[2].to_f
      }
    end

    def self.resolve_redirect(url)
      uri = URI(url)
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPRedirection
        response["location"]
      else
        url
      end
    rescue StandardError => e
      Rails.logger.error("Failed to resolve redirect: #{e.message}")
      nil
    end
  end
end
