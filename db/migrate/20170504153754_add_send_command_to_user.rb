class AddSendCommandToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :send_command, :boolean
  end
end
