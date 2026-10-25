class CreateCustomerPayments < ActiveRecord::Migration[7.2]
  def change
    create_table :customer_payments do |t|
      t.references :customer, null: false, foreign_key: true
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :payment_method
      t.text :notes
      t.datetime :received_at

      t.timestamps
    end
  end
end
