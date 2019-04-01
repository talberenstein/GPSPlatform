class CreateDrivers < ActiveRecord::Migration[5.0]
  def change
    create_table :drivers do |t|
      t.string :name
      t.string :rut
      t.belongs_to :company, foreign_key: true

      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
