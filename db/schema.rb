# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_02_122934) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "record_type", limit: 255, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
  end

  create_table "active_storage_blobs", id: :serial, force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "filename", limit: 255, null: false
    t.string "content_type", limit: 255
    t.text "metadata"
    t.string "service_name", limit: 255, null: false
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 255
    t.datetime "created_at", precision: nil, null: false
  end

  create_table "active_storage_variant_records", id: :serial, force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", limit: 255, null: false

    t.unique_constraint ["blob_id", "variation_digest"], name: "active_storage_variant_records_blob_id_variation_digest_key"
  end

  create_table "admin_users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false

    t.unique_constraint ["email"], name: "admin_users_email_key"
    t.unique_constraint ["reset_password_token"], name: "admin_users_reset_password_token_key"
  end

  create_table "genres", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "menu_genres", id: :serial, force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menu_noodles", id: :serial, force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "noodle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menu_soups", id: :serial, force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "soup_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "menus", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.bigint "shop_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "noodles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "shops", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "address", limit: 255, default: "", null: false
    t.string "google_map_url", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false

    t.unique_constraint ["google_map_url"], name: "shops_google_map_url_key"
  end

  create_table "soups", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", limit: 255
    t.string "name", limit: 255
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "google_id"
    t.string "image"
    t.boolean "email_verified", default: false
    t.index ["google_id"], name: "index_users_on_google_id", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id", name: "active_storage_variant_records_blob_id_fkey"
  add_foreign_key "menu_genres", "genres"
  add_foreign_key "menu_noodles", "menus"
  add_foreign_key "menu_soups", "menus"
end
