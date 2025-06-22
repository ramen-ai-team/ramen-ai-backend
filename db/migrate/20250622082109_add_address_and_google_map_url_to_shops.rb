class AddAddressAndGoogleMapUrlToShops < ActiveRecord::Migration[8.0]
  def change
    change_table :shops do |t|
      t.string :address, null: false, default: "", after: :name
      t.string :google_map_url, after: :address

      t.index :google_map_url, unique: true
    end
  end
end
