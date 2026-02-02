module JsonAPIHelper
  def json
    parsed = JSON.parse(response.body)
    if parsed.is_a?(Array)
      parsed.map(&:deep_symbolize_keys)
    else
      parsed.deep_symbolize_keys
    end
  end
end
