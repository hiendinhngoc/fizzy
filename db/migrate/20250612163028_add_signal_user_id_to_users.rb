class AddSignalUserIdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :signal_user_id, :integer
    add_index :users, :signal_user_id, unique: true
  end
end
