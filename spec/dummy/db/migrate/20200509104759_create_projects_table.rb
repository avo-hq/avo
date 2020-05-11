class CreateProjectsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :projects_users do |t|
      t.belongs_to :project
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
