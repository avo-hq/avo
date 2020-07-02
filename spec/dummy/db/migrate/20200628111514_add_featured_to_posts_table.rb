class AddFeaturedToPostsTable < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :featured, :boolean, default: false
  end
end
