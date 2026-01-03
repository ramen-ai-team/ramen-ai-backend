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

      match = target_url.match(/1s([^!]+)/)
      return nil unless match

      match[1]
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
