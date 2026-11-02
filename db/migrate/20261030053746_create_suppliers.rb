class CreateSuppliers < ActiveRecord::Migration[7.2]
  def change
    create_table :suppliers do |t|
      t.string :shop_name, null: false
      t.string :dealer_name
      t.string :phone
      t.text :notes

      t.timestamps
    end
    add_index :suppliers, :shop_name
  end
end
