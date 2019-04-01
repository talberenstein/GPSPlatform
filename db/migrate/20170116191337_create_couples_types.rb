class CreateCouplesTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :couples_types do |t|
      t.string :couple_name
      t.integer :high
      t.integer :width
      t.integer :long
      t.integer :weight

      t.timestamps
    end
  end
end
