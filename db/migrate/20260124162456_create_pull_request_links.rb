class CreatePullRequestLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :pull_request_links, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :card_id, null: false
      t.string :github_pr_url, null: false
      t.string :github_repo_full_name
      t.string :github_pr_number
      t.string :state, default: "open", null: false

      t.timestamps

      t.index [:card_id, :github_pr_url], unique: true
      t.index [:github_repo_full_name, :github_pr_number]
      t.index :account_id
    end
  end
end
