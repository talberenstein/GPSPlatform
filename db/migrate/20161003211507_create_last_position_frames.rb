class CreateLastPositionFrames < ActiveRecord::Migration[5.0]
  def change
    create_table :last_position_frames do |t|
      t.belongs_to :company, foreign_key: true
      t.string :event_id
      t.string :device_type
      t.string :imei
      t.string :frame_type
      t.column :gps_date, 'timestamp with time zone'
      t.geometry :geom
      t.decimal :velocity
      t.decimal :altitude
      t.decimal :direction
      t.integer :position_type
      t.integer :position_antiquity
      t.decimal :odometer
      t.boolean :ignition
      t.boolean :power_source
      t.boolean :output_1
      t.boolean :output_2
      t.boolean :input_1
      t.boolean :input_2
      t.boolean :input_3
      t.integer :seen_satellites
      t.decimal :battery_voltage
      t.boolean :gps_valid
      
      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
