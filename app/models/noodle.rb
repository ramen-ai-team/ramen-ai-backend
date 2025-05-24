class Noodle < ApplicationRecord
  has_many :menu_noodles, dependent: :destroy
  has_many :menus, through: :menu_noodles

  validates :name, presence: true, uniqueness: true
end
