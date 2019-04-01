class AddGroupToDevices < ActiveRecord::Migration[5.0]
  def change
    add_reference :devices, :group, foreign_key: true
  end
end
