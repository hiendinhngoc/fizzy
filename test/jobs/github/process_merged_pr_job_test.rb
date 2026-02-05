require "test_helper"

class Github::ProcessMergedPrJobTest < ActiveJob::TestCase
  test "closes cards with direct PR links" do
    link = pull_request_links(:logo_pr)
    card = link.card

    assert card.open?

    perform_enqueued_jobs do
      Github::ProcessMergedPrJob.perform_later(
        repo: "basecamp/fizzy",
        pr_number: "123",
        pr_body: ""
      )
    end

    assert link.reload.state == "merged"
    assert card.reload.closed?
  end

  test "closes cards referenced in PR body" do
    card = cards(:text)
    account = card.account
    account_slug = account.external_account_id

    assert card.open?

    perform_enqueued_jobs do
      Github::ProcessMergedPrJob.perform_later(
        repo: "some/repo",
        pr_number: "999",
        pr_body: "Fixes https://fizzy.com/#{account_slug}/cards/#{card.number}"
      )
    end

    assert card.reload.closed?
  end

  test "ignores cards in accounts without active integration" do
    card = cards(:radio) # initech account
    account = card.account
    account_slug = account.external_account_id

    assert card.open?
    assert_nil account.github_integration

    perform_enqueued_jobs do
      Github::ProcessMergedPrJob.perform_later(
        repo: "some/repo",
        pr_number: "999",
        pr_body: "Fixes https://fizzy.com/#{account_slug}/cards/#{card.number}"
      )
    end

    assert card.reload.open?
  end

  test "handles multiple cards in PR body" do
    account = accounts("37s")
    account_slug = account.external_account_id
    card1 = cards(:logo)
    card2 = cards(:text)

    assert card1.open?
    assert card2.open?

    perform_enqueued_jobs do
      Github::ProcessMergedPrJob.perform_later(
        repo: "some/repo",
        pr_number: "999",
        pr_body: <<~BODY
          This PR fixes multiple cards:
          - https://fizzy.com/#{account_slug}/cards/#{card1.number}
          - https://fizzy.com/#{account_slug}/cards/#{card2.number}
        BODY
      )
    end

    assert card1.reload.closed?
    assert card2.reload.closed?
  end

  test "handles blank PR body" do
    perform_enqueued_jobs do
      Github::ProcessMergedPrJob.perform_later(
        repo: "some/repo",
        pr_number: "999",
        pr_body: nil
      )
    end
    # No exception should be raised
  end
end
