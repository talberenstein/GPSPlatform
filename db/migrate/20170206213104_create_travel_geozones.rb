class CreateTravelGeozones < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_geozones do |t|
      t.integer :travel_sheet_id
      t.integer :travel_geozone_id

      t.timestamps
    end
  end
end
