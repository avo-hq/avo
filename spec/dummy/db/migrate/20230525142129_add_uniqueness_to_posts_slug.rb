class AddUniquenessToPostsSlug < ActiveRecord::Migration[6.1]
  def change
    add_index :posts, :slug, unique: true
  end
end
