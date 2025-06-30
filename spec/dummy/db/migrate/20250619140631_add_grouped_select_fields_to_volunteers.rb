class AddGroupedSelectFieldsToVolunteers < ActiveRecord::Migration[6.1]
  def change
    add_column :volunteers, :department, :string
    add_column :volunteers, :skills, :string, array: true, default: []
  end
end
