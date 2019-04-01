class AddDeviceToFrame < ActiveRecord::Migration[5.0]
  def change
    add_reference :frames, :device, foreign_key: true
  end
end
