class AddNotNullToShopsCoordinates < ActiveRecord::Migration[8.0]
  def up
    # NULL値が残っている場合は、先に rake shops:backfill_coordinates を実行してください

    change_column_null :shops, :latitude, false
    change_column_null :shops, :longitude, false
  end

  def down
    change_column_null :shops, :latitude, true
    change_column_null :shops, :longitude, true
  end
end
