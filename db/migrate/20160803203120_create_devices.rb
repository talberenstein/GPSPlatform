class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.string :imei
      t.string :name
      t.string :phone
      t.belongs_to :company, foreign_key: true
      t.belongs_to :driver, foreign_key: true

      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end