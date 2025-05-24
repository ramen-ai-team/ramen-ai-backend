class Noodle < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
