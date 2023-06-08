class RemoveDescriptionFromCity < ActiveRecord::Migration[6.1]
  def change
    remove_column :cities, :description
  end
end
