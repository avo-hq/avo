class AddStartingAtToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :starting_at, :time
  end
end
