class CreateTravelLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_locations do |t|
      t.integer :travel_sheet_id
      t.integer :location_id
      t.string :state
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
