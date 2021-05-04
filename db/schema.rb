ActiveRecord::Schema.define(version: 2021_05_03_013630) do

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

end
