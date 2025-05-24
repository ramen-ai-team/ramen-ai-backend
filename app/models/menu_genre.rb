class MenuGenre < ApplicationRecord
  belongs_to :menu
  belongs_to :genre
end
