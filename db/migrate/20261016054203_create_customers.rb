class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone
      t.text :address
      t.string :customer_code
      t.text :notes
      t.boolean :active

      t.timestamps
    end
  end
end
