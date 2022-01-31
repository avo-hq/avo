class AddUserIdToPerson < ActiveRecord::Migration[6.0]
  def change
    add_reference :people, :user, null: true, foreign_key: true
  end
end
