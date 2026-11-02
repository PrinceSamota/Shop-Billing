class CreateLibraryStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :library_students do |t|
      t.string :name
      t.string :phone
      t.date :admission_date
      t.decimal :monthly_fee
      t.string :status
      t.date :left_date
      t.text :notes

      t.timestamps
    end
  end
end
