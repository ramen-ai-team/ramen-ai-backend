class AddGoogleAuthToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_id, :string
    add_column :users, :image, :string
    add_column :users, :email_verified, :boolean, default: false

    add_index :users, :google_id, unique: true
  end
end
