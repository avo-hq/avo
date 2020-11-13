class AddDescriptionToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :description, :text
  end
end
