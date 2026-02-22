class Menu < ApplicationRecord
  belongs_to :shop
  has_one :menu_genre, dependent: :destroy
  has_one :genre, through: :menu_genre
  has_one :menu_noodle, dependent: :destroy
  has_one :noodle, through: :menu_noodle
  has_one :menu_soup, dependent: :destroy
  has_one :soup, through: :menu_soup

  has_one_attached :image

  validates :name, presence: true
  validates :image, attached: true

  def image_url
    puts ">>>>>> Menu#image_url called for menu_id=#{id}"
    return nil unless image.attached?

    # ADC対応: proxy URL を直接構築（署名不要）
    host = Rails.application.routes.default_url_options[:host]
    proxy_url = "#{host}/rails/active_storage/blobs/proxy/#{image.signed_id}/#{image.filename}"

    puts ">>>>>> Generated proxy URL: #{proxy_url}"
    proxy_url
  end
end
