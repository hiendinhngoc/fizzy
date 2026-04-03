module PullRequestLinksHelper
  # Brakeman can't infer model validations, so keep external URLs behind an explicit
  # allowlist check before feeding them into `link_to`.
  def safe_github_pull_request_url(pull_request_link)
    url = pull_request_link.github_pr_url.to_s
    return if url.blank?

    url if PullRequestLink::GITHUB_PR_URL_REGEX.match?(url)
  end
end
