class AddIconToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :icon, :string
  end
end
