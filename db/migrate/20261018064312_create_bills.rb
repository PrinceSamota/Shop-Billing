class CreateBills < ActiveRecord::Migration[7.2]
  def change
    create_table :bills do |t|
      t.references :customer, null: true, foreign_key: true

      t.string :bill_number
      t.string :status, null: false, default: "draft"

      t.decimal :subtotal, precision: 12, scale: 2, null: false, default: 0
      t.decimal :discount_amount, precision: 12, scale: 2, null: false, default: 0
      t.decimal :tax_amount, precision: 12, scale: 2, null: false, default: 0
      t.decimal :total_amount, precision: 12, scale: 2, null: false, default: 0
      t.decimal :paid_amount, precision: 12, scale: 2, null: false, default: 0

      t.string :payment_status, null: false, default: "unpaid"
      t.datetime :finalized_at

      t.timestamps
    end

    add_index :bills, :bill_number, unique: true
  end
end
