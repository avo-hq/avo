class AddUuidToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :uuid, :string, null: true
    add_index :users, :uuid, unique: true

    User.find_each do |user|
      user.update(uuid: SecureRandom.uuid) if user.uuid.nil?
    end

    change_column_null :users, :uuid, false
  end
end
