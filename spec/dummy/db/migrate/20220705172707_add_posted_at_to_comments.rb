class AddPostedAtToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :posted_at, :datetime
  end
end
