class GoogleMapsUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.match?(/\Ahttps?:\/\/maps\.app\.goo\.gl\//)
      record.errors.add(attribute, "は「https://maps.app.goo.gl/」から始まるGoogle Map URLにしてください")
    end
  end
end
