class AddPositionToCourseLinks < ActiveRecord::Migration[6.0]
  def change
    add_column :course_links, :position, :integer
  end
end
