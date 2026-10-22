class AddReferrerToStorePatrons < ActiveRecord::Migration[7.0]
  def change
    add_column :store_patrons, :referrer_id, :integer
  end
end
