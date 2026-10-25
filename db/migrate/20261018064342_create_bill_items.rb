class CreateBillItems < ActiveRecord::Migration[7.2]
  def change
    create_table :bill_items do |t|
      t.references :bill, null: false, foreign_key: true

      # Optional: manually entered item ka Product record zaroori nahi
      t.references :product, null: true, foreign_key: true

      # Product ka naam bill mein preserve rahega
      t.string :product_name, null: false
      t.string :sku
      t.decimal :quantity, precision: 12, scale: 3, null: false
      t.string :unit
      t.decimal :unit_price, precision: 12, scale: 2, null: false
      t.decimal :line_total, precision: 12, scale: 2, null: false

      t.timestamps
    end
  end
end
