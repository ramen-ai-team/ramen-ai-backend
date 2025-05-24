class Genre < ApplicationRecord
  has_many :menu_genres, dependent: :destroy
  has_many :menus, through: :menu_genres

  validates :name, presence: true, uniqueness: true
end
