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

ActiveRecord::Schema[7.2].define(version: 2026_11_01_131513) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bill_items", force: :cascade do |t|
    t.bigint "bill_id", null: false
    t.bigint "product_id"
    t.string "product_name", null: false
    t.string "sku"
    t.decimal "quantity", precision: 12, scale: 3, null: false
    t.string "unit"
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.decimal "line_total", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bill_id"], name: "index_bill_items_on_bill_id"
    t.index ["product_id"], name: "index_bill_items_on_product_id"
  end

  create_table "bills", force: :cascade do |t|
    t.bigint "customer_id"
    t.string "bill_number"
    t.string "status", default: "draft", null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "tax_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "paid_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "payment_status", default: "unpaid", null: false
    t.datetime "finalized_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "walk_in_name"
    t.index ["bill_number"], name: "index_bills_on_bill_number", unique: true
    t.index ["customer_id"], name: "index_bills_on_customer_id"
  end

  create_table "customer_payments", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "payment_method"
    t.text "notes"
    t.datetime "received_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_payments_on_customer_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.text "address"
    t.string "customer_code"
    t.text "notes"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
  end

  create_table "library_payments", force: :cascade do |t|
    t.bigint "library_student_id", null: false
    t.decimal "amount"
    t.date "payment_date"
    t.string "payment_method"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_student_id"], name: "index_library_payments_on_library_student_id"
  end

  create_table "library_students", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.date "admission_date"
    t.decimal "monthly_fee"
    t.string "status"
    t.date "left_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "fee_valid_till"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "sku"
    t.string "category"
    t.decimal "purchase_price"
    t.decimal "selling_price"
    t.decimal "stock_quantity"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "supplier_entries", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.string "entry_type", null: false
    t.date "entry_date", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["supplier_id", "entry_date"], name: "index_supplier_entries_on_supplier_id_and_entry_date"
    t.index ["supplier_id"], name: "index_supplier_entries_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "shop_name", null: false
    t.string "dealer_name"
    t.string "phone"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_name"], name: "index_suppliers_on_shop_name"
  end

  add_foreign_key "bill_items", "bills"
  add_foreign_key "bill_items", "products"
  add_foreign_key "bills", "customers"
  add_foreign_key "customer_payments", "customers"
  add_foreign_key "library_payments", "library_students"
  add_foreign_key "supplier_entries", "suppliers"
end
