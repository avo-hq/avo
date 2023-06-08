class RemoveDescriptionFromCity < ActiveRecord::Migration[6.0]
  def change
    remove_column :cities, :description
  end
end
