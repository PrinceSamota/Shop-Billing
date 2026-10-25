class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :sku
      t.string :category
      t.decimal :purchase_price
      t.decimal :selling_price
      t.decimal :stock_quantity
      t.string :unit

      t.timestamps
    end
  end
end
