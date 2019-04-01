class AddAmosToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :amos3005, :string
  end
end
