class AddSkillsToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :skills, :text, array: true, default: []
  end
end
