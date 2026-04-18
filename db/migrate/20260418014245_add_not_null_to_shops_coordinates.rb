class AddNotNullToShopsCoordinates < ActiveRecord::Migration[8.0]
  def up
    # NULL値が残っている場合はスキップ（先に rake shops:backfill_coordinates を実行してください）
    if Shop.where(latitude: nil).or(Shop.where(longitude: nil)).exists?
      puts "座標がNULLのshopが存在します。先に rake shops:backfill_coordinates を実行してください。"
    end

    change_column_null :shops, :latitude, false
    change_column_null :shops, :longitude, false
  end

  def down
    change_column_null :shops, :latitude, true
    change_column_null :shops, :longitude, true
  end
end
