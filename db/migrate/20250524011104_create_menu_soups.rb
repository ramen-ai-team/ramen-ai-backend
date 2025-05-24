class CreateMenuSoups < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_soups do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :soup, null: false, foreign_key: true

      t.timestamps
    end
  end
end
