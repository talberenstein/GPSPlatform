class AddIgnitionToFrame < ActiveRecord::Migration[5.0]
  def change
    add_column :frames, :ignition, :boolean
  end
end
