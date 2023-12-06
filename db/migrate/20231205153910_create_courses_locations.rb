class CreateCoursesLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :courses_locations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
