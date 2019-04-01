class CreateAllowedZones < ActiveRecord::Migration[5.0]
  def change
    create_table :allowed_zones do |t|
      t.string :geo_type
      t.geometry :geo
      t.integer :company_id
      t.integer :created_from
      t.integer :modified_from

      t.timestamps
    end
  end
end
