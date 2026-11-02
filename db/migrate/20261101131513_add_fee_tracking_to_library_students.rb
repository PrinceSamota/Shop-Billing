class AddFeeTrackingToLibraryStudents < ActiveRecord::Migration[7.2]
  def change
    add_column :library_students, :fee_valid_till, :date
  end
end
