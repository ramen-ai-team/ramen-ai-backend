class Shop < ApplicationRecord
  has_many :menus, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true, length: { maximum: 255 }
  validates :google_map_url, presence: true, length: { maximum: 255 }
end
