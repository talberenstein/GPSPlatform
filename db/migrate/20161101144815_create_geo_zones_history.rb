class CreateGeoZonesHistory < ActiveRecord::Migration[5.0]
  def change
    create_table :geo_zones_histories do |t|
      t.references :geo_zone, foreign_key: true
      t.datetime :enter_time, 'timestamp with time zone'
      t.geometry :enter_location
      t.decimal :enter_odometer
      t.datetime :exit_time, 'timestamp with time zone'
      t.geometry :exit_location
      t.decimal :exit_odometer
      t.references :device, foreign_key: true
      t.references :company, foreign_key: true

      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
