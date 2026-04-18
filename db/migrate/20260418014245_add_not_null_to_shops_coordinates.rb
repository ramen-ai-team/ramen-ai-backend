class AddNotNullToShopsCoordinates < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    null_count = execute("SELECT COUNT(*) FROM shops WHERE latitude IS NULL OR longitude IS NULL").first["count"].to_i
    if null_count > 0
      puts "座標がNULLのshopが #{null_count}件 存在します。先に rake shops:backfill_coordinates を実行してください。"
    end

    change_column_null :shops, :latitude, false
    change_column_null :shops, :longitude, false
  end

  def down
    change_column_null :shops, :latitude, true
    change_column_null :shops, :longitude, true
  end
end
