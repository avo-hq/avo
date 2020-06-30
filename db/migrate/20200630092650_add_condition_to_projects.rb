class AddConditionToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :condition, :text, :default => 'success'
  end
end
