class Menu < ApplicationRecord
  belongs_to :shop
  has_one :menu_genre, dependent: :destroy
  has_one :genre, through: :menu_genre
  has_one :menu_noodle, dependent: :destroy
  has_one :noodle, through: :menu_noodle
  has_one :menu_soup, dependent: :destroy
  has_one :soup, through: :menu_soup

  has_one_attached :image
  has_many :menu_reports, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :name, presence: true
  validates :image, attached: true

  def image_url
    return nil unless image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: false)
  end
end
