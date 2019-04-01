class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :name

      t.datetime :inserted_at, null: false
      t.datetime :updated_at, null: false
    end
  end
end
