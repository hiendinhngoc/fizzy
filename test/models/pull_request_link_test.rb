require "test_helper"

class PullRequestLinkTest < ActiveSupport::TestCase
  test "create with valid PR URL" do
    link = cards(:logo).pull_request_links.create!(
      github_pr_url: "https://github.com/basecamp/fizzy/pull/999"
    )

    assert link.persisted?
    assert_equal "basecamp/fizzy", link.github_repo_full_name
    assert_equal "999", link.github_pr_number
    assert_equal "open", link.state
  end

  test "extracts PR details from URL" do
    link = PullRequestLink.new(
      card: cards(:logo),
      github_pr_url: "https://github.com/owner/repo/pull/42"
    )
    link.valid?

    assert_equal "owner/repo", link.github_repo_full_name
    assert_equal "42", link.github_pr_number
  end

  test "validates PR URL format" do
    link = PullRequestLink.new(card: cards(:logo), github_pr_url: "not a url")
    assert_not link.valid?
    assert_includes link.errors[:github_pr_url], "is invalid"

    link = PullRequestLink.new(card: cards(:logo), github_pr_url: "https://gitlab.com/owner/repo/pull/1")
    assert_not link.valid?
    assert_includes link.errors[:github_pr_url], "is invalid"

    link = PullRequestLink.new(card: cards(:logo), github_pr_url: "https://github.com/owner/repo/issues/1")
    assert_not link.valid?
    assert_includes link.errors[:github_pr_url], "is invalid"
  end

  test "validates uniqueness per card" do
    existing = pull_request_links(:logo_pr)

    link = PullRequestLink.new(
      card: existing.card,
      github_pr_url: existing.github_pr_url
    )
    assert_not link.valid?
    assert_includes link.errors[:github_pr_url], "has already been taken"
  end

  test "for_pr scope" do
    link = pull_request_links(:logo_pr)

    found = PullRequestLink.for_pr("basecamp/fizzy", 123)
    assert_includes found, link

    not_found = PullRequestLink.for_pr("other/repo", 123)
    assert_not_includes not_found, link
  end

  test "mark_merged closes the card" do
    link = pull_request_links(:logo_pr)
    card = link.card

    assert card.open?

    link.mark_merged!

    assert_equal "merged", link.reload.state
    assert card.reload.closed?
  end

  test "mark_merged does not close already closed card" do
    link = pull_request_links(:logo_pr)
    card = link.card
    card.close(user: card.account.system_user)

    assert card.closed?

    link.mark_merged!

    assert_equal "merged", link.reload.state
    assert card.reload.closed?
  end
end
