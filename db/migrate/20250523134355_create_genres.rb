class CreateGenres < ActiveRecord::Migration[8.0]
  def change
    create_table :genres do |t|
      t.string :name, null: false

      t.timestamps
      t.index :name, unique: true
    end
  end
end
