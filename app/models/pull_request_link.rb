class PullRequestLink < ApplicationRecord
  GITHUB_PR_URL_REGEX = %r{
    \Ahttps://github\.com/
    (?<owner>[^/]+)/
    (?<repo>[^/]+)/
    pull/
    (?<number>\d+)
    (?:\?[^\s]*)?\z
  }x

  belongs_to :account, default: -> { card.account }
  belongs_to :card, touch: true

  validates :github_pr_url, presence: true, format: { with: GITHUB_PR_URL_REGEX }
  validates :github_pr_url, uniqueness: { scope: :card_id }

  before_validation :extract_pr_details

  scope :for_pr, ->(repo, number) { where(github_repo_full_name: repo, github_pr_number: number.to_s) }
  scope :open, -> { where(state: "open") }
  scope :merged, -> { where(state: "merged") }

  def mark_merged!(user: account.system_user)
    transaction do
      update!(state: "merged")
      card.close(user: user) if card.open?
    end
  end

  private
    def extract_pr_details
      if match = github_pr_url&.match(GITHUB_PR_URL_REGEX)
        self.github_repo_full_name = "#{match[:owner]}/#{match[:repo]}"
        self.github_pr_number = match[:number]
      end
    end
end
