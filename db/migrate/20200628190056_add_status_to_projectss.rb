class AddStatusToProjectss < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :status, :text, default: 'running'
  end
end
