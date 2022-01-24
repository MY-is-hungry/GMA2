# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_06_22_121817) do

  create_table "commutes", force: :cascade do |t|
    t.string "user_id", null: false
    t.float "start_lat"
    t.float "start_lng"
    t.float "end_lat"
    t.float "end_lng"
    t.string "mode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "search_area"
    t.string "avoid"
    t.string "start_address"
    t.string "end_address"
    t.integer "setup_id"
    t.boolean "first_setup"
    t.string "start_city"
    t.string "end_city"
    t.index ["setup_id"], name: "index_commutes_on_setup_id"
    t.index ["user_id"], name: "index_commutes_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "setups", force: :cascade do |t|
    t.string "content"
    t.string "label"
    t.string "next_setup"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_users_on_id", unique: true
  end

  create_table "via_places", force: :cascade do |t|
    t.integer "commute_id", null: false
    t.float "via_lat"
    t.float "via_lng"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commute_id"], name: "index_via_places_on_commute_id"
  end

  add_foreign_key "commutes", "setups"
  add_foreign_key "commutes", "users"
  add_foreign_key "favorites", "users"
  add_foreign_key "via_places", "commutes"
end
