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

ActiveRecord::Schema.define(version: 2019_03_14_072347) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "refunds", force: :cascade do |t|
    t.string "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label_issued", default: "Incomplete"
    t.string "items_returned", default: "Incomplete"
    t.string "payment_refunded", default: "Incomplete"
    t.string "refund_method", default: "Primary"
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "giftcard_id"
    t.string "label_url"
    t.string "order_number"
    t.string "phone_number"
    t.string "items"
    t.string "reason"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

end
