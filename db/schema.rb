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

ActiveRecord::Schema[8.0].define(version: 2025_05_24_011104) do
  create_table "genres", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_genres_on_name", unique: true
  end

  create_table "menu_genres", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_menu_genres_on_genre_id"
    t.index ["menu_id"], name: "index_menu_genres_on_menu_id"
  end

  create_table "menu_noodles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "noodle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_menu_noodles_on_menu_id"
    t.index ["noodle_id"], name: "index_menu_noodles_on_noodle_id"
  end

  create_table "menu_soups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "menu_id", null: false
    t.bigint "soup_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["menu_id"], name: "index_menu_soups_on_menu_id"
    t.index ["soup_id"], name: "index_menu_soups_on_soup_id"
  end

  create_table "menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "shop_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_menus_on_shop_id"
  end

  create_table "noodles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_noodles_on_name", unique: true
  end

  create_table "shops", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "soups", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_soups_on_name", unique: true
  end

  add_foreign_key "menu_genres", "genres"
  add_foreign_key "menu_genres", "menus"
  add_foreign_key "menu_noodles", "menus"
  add_foreign_key "menu_noodles", "noodles"
  add_foreign_key "menu_soups", "menus"
  add_foreign_key "menu_soups", "soups"
  add_foreign_key "menus", "shops"
end
