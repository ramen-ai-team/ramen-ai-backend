class CreateMenuNoodles < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_noodles do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :noodle, null: false, foreign_key: true

      t.timestamps
    end
  end
end
