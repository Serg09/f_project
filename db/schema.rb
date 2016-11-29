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

ActiveRecord::Schema.define(version: 20161129030641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "recipient",    limit: 100, null: false
    t.string   "line_1",       limit: 100, null: false
    t.string   "line_2",       limit: 100
    t.string   "city",         limit: 100, null: false
    t.string   "state",        limit: 20,  null: false
    t.string   "postal_code",  limit: 10,  null: false
    t.string   "country_code", limit: 2,   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "batches", force: :cascade do |t|
    t.string   "status",     default: "new", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "book_identifiers", force: :cascade do |t|
    t.integer  "client_id",             null: false
    t.integer  "book_id",               null: false
    t.string   "code",       limit: 20, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "book_identifiers", ["book_id"], name: "index_book_identifiers_on_book_id", using: :btree
  add_index "book_identifiers", ["client_id", "code"], name: "index_book_identifiers_on_client_id_and_code", unique: true, using: :btree

  create_table "books", force: :cascade do |t|
    t.string   "isbn",       limit: 13,  null: false
    t.string   "title",      limit: 250, null: false
    t.string   "format",     limit: 100, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "books", ["isbn"], name: "index_books_on_isbn", unique: true, using: :btree
  add_index "books", ["title"], name: "index_books_on_title", using: :btree

  create_table "carriers", force: :cascade do |t|
    t.string   "name",       limit: 100, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "carriers", ["name"], name: "index_carriers_on_name", unique: true, using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name",                         limit: 100, null: false
    t.string   "abbreviation",                 limit: 5,   null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "order_import_processor_class", limit: 250
    t.string   "auth_token",                   limit: 40,  null: false
  end

  add_index "clients", ["abbreviation"], name: "index_clients_on_abbreviation", unique: true, using: :btree
  add_index "clients", ["auth_token"], name: "index_clients_on_auth_token", unique: true, using: :btree
  add_index "clients", ["name"], name: "index_clients_on_name", unique: true, using: :btree

  create_table "documents", force: :cascade do |t|
    t.string   "source"
    t.string   "filename"
    t.text     "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id",                                       null: false
    t.integer  "line_item_no",                                   null: false
    t.string   "sku",                 limit: 30,                 null: false
    t.string   "description",         limit: 50
    t.integer  "quantity",                                       null: false
    t.decimal  "unit_price"
    t.decimal  "discount_percentage"
    t.decimal  "freight_charge"
    t.decimal  "tax"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "status",              limit: 30, default: "new", null: false
    t.integer  "accepted_quantity"
    t.integer  "shipped_quantity"
    t.decimal  "weight"
  end

  add_index "order_items", ["order_id", "line_item_no"], name: "index_order_items_on_order_id_and_line_item_no", unique: true, using: :btree
  add_index "order_items", ["sku"], name: "index_order_items_on_sku", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "customer_name",       limit: 50
    t.string   "telephone",           limit: 25
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.date     "order_date",                                            null: false
    t.integer  "batch_id"
    t.string   "status",              limit: 30,  default: "incipient", null: false
    t.text     "error"
    t.integer  "client_id",                                             null: false
    t.string   "client_order_id",     limit: 100
    t.string   "customer_email",      limit: 100
    t.integer  "ship_method_id"
    t.integer  "shipping_address_id"
    t.string   "confirmation",        limit: 32
  end

  add_index "orders", ["batch_id"], name: "index_orders_on_batch_id", using: :btree
  add_index "orders", ["client_id"], name: "index_orders_on_client_id", using: :btree
  add_index "orders", ["client_order_id"], name: "index_orders_on_client_order_id", unique: true, using: :btree
  add_index "orders", ["confirmation"], name: "index_orders_on_confirmation", unique: true, using: :btree
  add_index "orders", ["ship_method_id"], name: "index_orders_on_ship_method_id", using: :btree

  create_table "packages", force: :cascade do |t|
    t.integer  "shipment_item_id", null: false
    t.string   "package_id"
    t.string   "tracking_number"
    t.integer  "quantity"
    t.decimal  "weight"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "packages", ["package_id"], name: "index_packages_on_package_id", using: :btree
  add_index "packages", ["shipment_item_id"], name: "index_packages_on_shipment_item_id", using: :btree
  add_index "packages", ["tracking_number"], name: "index_packages_on_tracking_number", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "order_id",                                         null: false
    t.decimal  "amount",                   precision: 9, scale: 2, null: false
    t.string   "state",        limit: 20,                          null: false
    t.string   "external_id",  limit: 100
    t.decimal  "external_fee",             precision: 9, scale: 2
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "payments", ["external_id"], name: "index_payments_on_external_id", unique: true, using: :btree
  add_index "payments", ["order_id"], name: "index_payments_on_order_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.string   "sku",         limit: 30,                          null: false
    t.string   "description", limit: 256,                         null: false
    t.decimal  "price",                   precision: 9, scale: 2
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "products", ["sku"], name: "index_products_on_sku", unique: true, using: :btree

  create_table "responses", force: :cascade do |t|
    t.integer  "payment_id", null: false
    t.string   "status",     null: false
    t.text     "content",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "responses", ["payment_id"], name: "index_responses_on_payment_id", using: :btree

  create_table "ship_methods", force: :cascade do |t|
    t.integer  "carrier_id",               null: false
    t.string   "description",  limit: 100, null: false
    t.string   "abbreviation", limit: 20,  null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "ship_methods", ["abbreviation"], name: "index_ship_methods_on_abbreviation", unique: true, using: :btree
  add_index "ship_methods", ["carrier_id", "description"], name: "index_ship_methods_on_carrier_id_and_description", unique: true, using: :btree

  create_table "shipment_items", force: :cascade do |t|
    t.integer  "shipment_id",      null: false
    t.integer  "order_item_id",    null: false
    t.integer  "external_line_no", null: false
    t.string   "sku",              null: false
    t.decimal  "unit_price"
    t.integer  "shipped_quantity", null: false
    t.string   "cancel_code"
    t.string   "cancel_reason"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "shipment_items", ["shipment_id", "order_item_id"], name: "index_shipment_items_on_shipment_id_and_order_item_id", using: :btree
  add_index "shipment_items", ["sku"], name: "index_shipment_items_on_sku", using: :btree

  create_table "shipments", force: :cascade do |t|
    t.integer  "order_id",                               null: false
    t.string   "external_id",                            null: false
    t.date     "ship_date",                              null: false
    t.integer  "quantity",                               null: false
    t.decimal  "weight"
    t.decimal  "freight_charge"
    t.decimal  "handling_charge"
    t.boolean  "collect_freight",        default: false, null: false
    t.string   "freight_responsibility"
    t.string   "cancel_code"
    t.string   "cancel_reason"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "shipments", ["external_id"], name: "index_shipments_on_external_id", using: :btree
  add_index "shipments", ["order_id"], name: "index_shipments_on_order_id", using: :btree
  add_index "shipments", ["ship_date"], name: "index_shipments_on_ship_date", using: :btree

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
