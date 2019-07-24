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

ActiveRecord::Schema.define(version: 2019_07_24_110327) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "auction_infos", force: :cascade do |t|
    t.bigint "bid"
    t.string "time_left"
    t.bigint "auction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_auction_infos_on_auction_id"
  end

  create_table "auctions", force: :cascade do |t|
    t.bigint "auc"
    t.bigint "item"
    t.string "owner"
    t.string "owner_realm"
    t.integer "quantity"
    t.bigint "buyout"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auc"], name: "index_auctions_on_auc"
  end

  create_table "items", force: :cascade do |t|
    t.integer "item_id"
    t.string "name"
    t.string "locale"
    t.string "media"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_items_on_item_id"
  end

end
