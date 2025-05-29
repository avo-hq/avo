class CreateCourseLinkVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :course_link_visits do |t|
      t.references :course_link, null: false, foreign_key: true
      t.datetime :visited_at
      t.string :ip_address

      t.timestamps
    end
  end
end
