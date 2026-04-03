require "test_helper"

class Github::WebhooksControllerTest < ActionDispatch::IntegrationTest
  test "create with valid signature processes merged PR" do
    link = pull_request_links(:logo_pr)
    integration = github_integrations(:signals)
    payload = build_pr_merged_payload("basecamp/fizzy", 123)
    signature = sign_payload(payload, integration.webhook_secret)

    assert_enqueued_with(job: Github::ProcessMergedPrJob) do
      post github_webhooks_path,
        params: payload,
        headers: {
          "Content-Type" => "application/json",
          "X-GitHub-Event" => "pull_request",
          "X-Hub-Signature-256" => signature
        }
    end

    assert_response :ok
  end

  test "create with invalid signature returns bad request" do
    payload = build_pr_merged_payload("basecamp/fizzy", 123)

    post github_webhooks_path,
      params: payload,
      headers: {
        "Content-Type" => "application/json",
        "X-GitHub-Event" => "pull_request",
        "X-Hub-Signature-256" => "sha256=invalid"
      }

    assert_response :bad_request
  end

  test "create ignores non-merged PRs" do
    link = pull_request_links(:logo_pr)
    integration = github_integrations(:signals)
    payload = build_pr_closed_payload("basecamp/fizzy", 123, merged: false)
    signature = sign_payload(payload, integration.webhook_secret)

    assert_no_enqueued_jobs(only: Github::ProcessMergedPrJob) do
      post github_webhooks_path,
        params: payload,
        headers: {
          "Content-Type" => "application/json",
          "X-GitHub-Event" => "pull_request",
          "X-Hub-Signature-256" => signature
        }
    end

    assert_response :ok
  end

  test "create ignores non-pull_request events" do
    integration = github_integrations(:signals)
    payload = '{"action":"created"}'
    signature = sign_payload(payload, integration.webhook_secret)

    assert_no_enqueued_jobs(only: Github::ProcessMergedPrJob) do
      post github_webhooks_path,
        params: payload,
        headers: {
          "Content-Type" => "application/json",
          "X-GitHub-Event" => "issues",
          "X-Hub-Signature-256" => signature
        }
    end

    assert_response :ok
  end

  private
    def sign_payload(payload, secret)
      "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, payload)}"
    end

    def build_pr_merged_payload(repo, number)
      build_pr_closed_payload(repo, number, merged: true)
    end

    def build_pr_closed_payload(repo, number, merged:)
      {
        action: "closed",
        repository: { full_name: repo },
        pull_request: {
          number: number,
          merged: merged,
          body: "Fixes card #123"
        }
      }.to_json
    end
end
