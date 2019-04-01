class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :name
      t.string :syrus
      t.string :tk103
      
      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
