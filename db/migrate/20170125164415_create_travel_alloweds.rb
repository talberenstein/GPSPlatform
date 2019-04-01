class CreateTravelAlloweds < ActiveRecord::Migration[5.0]
  def change
    create_table :travel_alloweds do |t|
      t.integer :travel_sheet_id

      t.timestamps
    end
  end
end
