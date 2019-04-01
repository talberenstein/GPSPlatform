class CreateDeviceEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :device_events do |t|
      t.boolean :is_alert
      t.belongs_to :device, foreign_key: true
      t.belongs_to :event, foreign_key: true
      t.belongs_to :company, foreign_key: true
      
      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
