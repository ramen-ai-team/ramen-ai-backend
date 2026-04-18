class MenuReport < ApplicationRecord
  belongs_to :user
  belongs_to :menu
  belongs_to :genre
  belongs_to :noodle
  belongs_to :soup

  has_many_attached :images

  validates :user_id, uniqueness: { scope: :menu_id }

  def image_urls
    images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image, only_path: false) }
  end
end
