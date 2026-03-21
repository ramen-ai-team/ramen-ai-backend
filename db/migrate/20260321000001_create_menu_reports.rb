class CreateMenuReports < ActiveRecord::Migration[8.0]
  def change
    create_table :menu_reports do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :menu, null: false, foreign_key: true, index: false
      t.references :genre, null: false, foreign_key: true, index: false
      t.references :noodle, null: false, foreign_key: true, index: false
      t.references :soup, null: false, foreign_key: true, index: false

      t.timestamps
    end

    add_index :menu_reports, [:user_id, :menu_id], unique: true
  end
end
