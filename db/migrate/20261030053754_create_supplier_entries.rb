class CreateSupplierEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :supplier_entries do |t|
      t.references :supplier, null: false, foreign_key: true

      t.string :entry_type, null: false
      t.date :entry_date, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.text :note

      t.timestamps
    end

    add_index :supplier_entries, [:supplier_id, :entry_date]
  end
end