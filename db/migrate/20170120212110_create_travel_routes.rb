class CreateTravelRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_routes do |t|
      t.integer :travel_id
      t.integer :route_id

      t.timestamps
    end
  end
end
