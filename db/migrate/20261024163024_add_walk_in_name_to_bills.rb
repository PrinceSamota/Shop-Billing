class AddWalkInNameToBills < ActiveRecord::Migration[7.2]
  def change
    add_column :bills, :walk_in_name, :string
  end
end
