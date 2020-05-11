class CreatePostsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.string :name
      t.text :body
      t.timestamp :published_at
      t.belongs_to :user

      t.timestamps null: false
    end
  end
end
