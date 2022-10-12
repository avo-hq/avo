class AddStartingAtToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :starting_at, :datetime
  end
end
