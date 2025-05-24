class Soup < ApplicationRecord
  has_many :menu_soups, dependent: :destroy
  has_many :menus, through: :menu_soups

  validates :name, presence: true, uniqueness: true
end
