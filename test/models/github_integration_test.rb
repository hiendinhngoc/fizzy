require "test_helper"

class GithubIntegrationTest < ActiveSupport::TestCase
  test "create generates webhook_secret" do
    integration = accounts(:initech).create_github_integration!
    assert integration.persisted?
    assert integration.active?
    assert integration.webhook_secret.present?
  end

  test "verify_signature with valid signature" do
    integration = github_integrations(:signals)
    payload = '{"action":"closed"}'
    signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', integration.webhook_secret, payload)}"

    assert integration.verify_signature(payload, signature)
  end

  test "verify_signature with invalid signature" do
    integration = github_integrations(:signals)
    payload = '{"action":"closed"}'
    signature = "sha256=invalidsignature"

    assert_not integration.verify_signature(payload, signature)
  end

  test "verify_signature with blank signature" do
    integration = github_integrations(:signals)
    payload = '{"action":"closed"}'

    assert_not integration.verify_signature(payload, nil)
    assert_not integration.verify_signature(payload, "")
  end

  test "deactivate and activate" do
    integration = github_integrations(:signals)

    assert_changes -> { integration.active? }, from: true, to: false do
      integration.deactivate!
    end

    assert_changes -> { integration.active? }, from: false, to: true do
      integration.activate!
    end
  end

  test "account can only have one integration" do
    account = accounts("37s")
    assert account.github_integration.present?

    assert_raises(ActiveRecord::RecordNotUnique) do
      GithubIntegration.create!(account: account)
    end
  end
end
