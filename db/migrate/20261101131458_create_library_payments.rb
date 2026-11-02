class CreateLibraryPayments < ActiveRecord::Migration[7.2]
  def change
    create_table :library_payments do |t|
      t.references :library_student, null: false, foreign_key: true
      t.decimal :amount
      t.date :payment_date
      t.string :payment_method
      t.text :notes

      t.timestamps
    end
  end
end
