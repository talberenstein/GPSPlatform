class CreateAlerts < ActiveRecord::Migration[5.0]
  def change
    create_table :alerts do |t|
      t.belongs_to :device, foreign_key: true
      t.belongs_to :event, foreign_key: true
      t.belongs_to :company, foreign_key: true
      t.column :gps_date, 'timestamp with time zone'
      t.geometry :geom
      t.boolean :seen
      t.string :description, default: ''
      
      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
