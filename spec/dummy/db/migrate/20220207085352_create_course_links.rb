class CreateCourseLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :course_links do |t|
      t.string :link
      t.belongs_to :course

      t.timestamps
    end
  end
end
