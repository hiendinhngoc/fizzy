class Github::WebhooksController < ApplicationController
  skip_before_action :require_account
  allow_unauthenticated_access
  skip_forgery_protection

  def create
    if payload = verified_payload
      dispatch_event(payload)
      head :ok
    else
      head :bad_request
    end
  end

  private
    def dispatch_event(payload)
      case request.headers["X-GitHub-Event"]
      when "pull_request"
        handle_pull_request_event(payload)
      end
    end

    def handle_pull_request_event(payload)
      return unless payload["action"] == "closed" && payload.dig("pull_request", "merged")

      Github::ProcessMergedPrJob.perform_later(
        repo: payload.dig("repository", "full_name"),
        pr_number: payload.dig("pull_request", "number").to_s,
        pr_body: payload.dig("pull_request", "body")
      )
    end

    def verified_payload
      payload = request.body.read
      signature = request.headers["X-Hub-Signature-256"]

      # Try all active integrations to verify the signature
      # This is needed because we don't know which account the webhook is for
      GithubIntegration.active.find_each do |integration|
        if integration.verify_signature(payload, signature)
          return JSON.parse(payload)
        end
      end

      nil
    rescue JSON::ParserError
      nil
    end
end
