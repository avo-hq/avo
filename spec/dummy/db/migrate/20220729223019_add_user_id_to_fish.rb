class AddUserIdToFish < ActiveRecord::Migration[6.0]
  def change
    add_reference :fish, :user, null: true, foreign_key: true
  end
end
