class AddGroupedSelectFieldsToVolunteers < ActiveRecord::Migration[8.0]
  def change
    add_column :volunteers, :department, :string
    add_column :volunteers, :skills, :string, array: true, default: []
  end
end
