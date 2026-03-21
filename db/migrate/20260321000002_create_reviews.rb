class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :menu, null: false, foreign_key: true, index: false
      t.references :user, null: false, foreign_key: true, index: false
      t.integer :rating, null: false
      t.text :comment, null: false
      t.date :visited_at, null: false

      t.timestamps
    end
  end
end
