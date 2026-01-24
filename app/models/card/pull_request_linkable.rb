module Card::PullRequestLinkable
  extend ActiveSupport::Concern

  included do
    has_many :pull_request_links, dependent: :destroy
  end

  def link_pull_request(url, user: Current.user)
    pull_request_links.create!(github_pr_url: url).tap do
      track_event :pull_request_linked, creator: user, particulars: { url: url }
    end
  end

  def unlink_pull_request(link, user: Current.user)
    link.destroy!
    track_event :pull_request_unlinked, creator: user, particulars: { url: link.github_pr_url }
  end
end
