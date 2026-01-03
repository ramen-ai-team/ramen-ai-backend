class Shop < ApplicationRecord
  has_many :menus, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :google_map_url, presence: true, length: { maximum: 255 }, uniqueness: true
  validate :google_maps_url_format

  private

  def google_maps_url_format
    return if google_map_url.blank?

    valid_patterns = [
      %r{\Ahttps?://maps\.app\.goo\.gl/},
      %r{\Ahttps?://.*google\.com/maps}
    ]

    unless valid_patterns.any? { |pattern| google_map_url.match?(pattern) }
      errors.add(:google_map_url, "must be a valid Google Maps URL")
    end
  end
end
