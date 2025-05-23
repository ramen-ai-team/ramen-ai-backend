class Shop < ApplicationRecord
  has_many :menus, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
end
