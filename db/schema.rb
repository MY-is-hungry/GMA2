# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_26_050150) do

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
    t.index ["user_id"], name: "index_commutes_on_user_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.string "user_id", null: false
    t.string "place_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_favorites_on_user_id"
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

end
