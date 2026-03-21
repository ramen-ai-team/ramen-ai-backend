class Review < ApplicationRecord
  belongs_to :menu
  belongs_to :user

  validates :rating, presence: true, numericality: { only_integer: true, in: 1..5 }
  validates :visited_at, presence: true
end
