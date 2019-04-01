class CreateDailyActivityHistory < ActiveRecord::Migration[5.0]
  def change
    create_table :daily_activity_histories do |t|
      t.references :device, foreign_key: true
      t.references :company, foreign_key: true
      t.decimal :driving_hours
      t.decimal :driving_distance
      t.date :day

      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
