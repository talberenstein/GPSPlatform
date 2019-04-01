class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :location_name
      t.string :location_address
      t.geometry :coordinate
      t.boolean :displayed

      t.timestamps
    end
  end
end
