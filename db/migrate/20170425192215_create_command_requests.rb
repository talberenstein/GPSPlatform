class CreateCommandRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :command_requests do |t|
      t.belongs_to :user, foreign_key: true, index: true
      t.datetime :request_time
      t.string :command_text
      t.integer :status
      t.datetime :result_time
      t.belongs_to :device, foreign_key: true, index: true

      t.timestamps
    end
  end
end
