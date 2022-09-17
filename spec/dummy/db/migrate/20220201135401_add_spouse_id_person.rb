class AddSpouseIdPerson < ActiveRecord::Migration[6.0]
  def change
    add_reference :people, :person, null: true, foreign_key: true
  end
end
