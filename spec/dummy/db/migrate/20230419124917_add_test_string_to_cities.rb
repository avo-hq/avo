class AddTestStringToCities < ActiveRecord::Migration[6.1]
  def change
    add_column :cities, :test_string, :string
  end
end
