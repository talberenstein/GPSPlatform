class CreateOwners < ActiveRecord::Migration[5.0]
  def change
    create_table :owners do |t|
      t.string :owner_name
      t.integer :location_id

      t.timestamps
    end
  end
end
