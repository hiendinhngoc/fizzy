class CreateGithubIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :github_integrations, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.string :webhook_secret, null: false
      t.boolean :active, default: true, null: false

      t.timestamps

      t.index :account_id, unique: true
    end
  end
end
