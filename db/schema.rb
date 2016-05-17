# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160517033446) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "batches", force: :cascade do |t|
    t.string   "status",     default: "new", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",                       null: false
    t.integer  "line_item_no",                   null: false
    t.string   "sku",                 limit: 30, null: false
    t.string   "description",         limit: 50
    t.integer  "quantity",                       null: false
    t.decimal  "price"
    t.decimal  "discount_percentage"
    t.decimal  "freight_charge"
    t.decimal  "tax"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "order_items", ["order_id", "line_item_no"], name: "index_order_items_on_order_id_and_line_item_no", unique: true, using: :btree
  add_index "order_items", ["sku"], name: "index_order_items_on_sku", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "customer_name", limit: 50,                 null: false
    t.string   "address_1",     limit: 50,                 null: false
    t.string   "address_2",     limit: 50
    t.string   "city",          limit: 50
    t.string   "state",         limit: 2
    t.string   "postal_code",   limit: 10
    t.string   "country_code",  limit: 3
    t.string   "telephone",     limit: 25
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.date     "order_date",                               null: false
    t.integer  "batch_id"
    t.string   "status",        limit: 30, default: "new", null: false
  end

  add_index "orders", ["batch_id"], name: "index_orders_on_batch_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 21
    t.string   "last_sign_in_ip",        limit: 21
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
