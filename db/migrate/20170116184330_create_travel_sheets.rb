class CreateTravelSheets < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_sheets do |t|
      t.string :travel_name
      t.string :state
      t.boolean :isTemplate
      t.integer :device
      t.integer :coupled
      t.integer :driver
      t.integer :owner_
      t.integer :origin_travel
      t.integer :travel_location
      t.datetime :time_origin_travel
      t.integer :final_travel
      t.datetime :time_final_travel
      t.datetime :time_travel_comeback
      t.integer :allow_stopped_zone
      t.integer :route

      t.timestamps
    end
  end
end
