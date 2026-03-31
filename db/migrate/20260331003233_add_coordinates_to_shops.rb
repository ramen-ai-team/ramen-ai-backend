class AddCoordinatesToShops < ActiveRecord::Migration[8.0]
  def change
    add_column :shops, :latitude, :float
    add_column :shops, :longitude, :float
  end
end
