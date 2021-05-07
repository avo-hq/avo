class AddProgressToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :progress, :integer
  end
end
