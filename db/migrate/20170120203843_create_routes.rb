class CreateRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :routes do |t|
      t.string :route_name
      t.geometry :route_geo
      t.datetime :route_duration
      t.boolean :route_toll
      t.integer :route_distance

      t.timestamps
    end
  end
end
