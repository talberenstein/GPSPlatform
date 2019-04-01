class CreateGeoZones < ActiveRecord::Migration[5.0]
  def change
    create_table :geo_zones do |t|
      t.string :name
      t.geometry :geom
      t.belongs_to :company, foreign_key: true
      t.boolean :enter_alert, default: false
      t.boolean :exit_alert, default: false
      t.decimal :radius, default: 0

      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
