class Github::ProcessMergedPrJob < ApplicationJob
  FIZZY_CARD_URL_PATTERN = %r{
    (?:https?://)?
    (?:www\.)?fizzy\.(?:com|do|localhost:\d+)/
    (\d{7,})/                # account slug (external_account_id)
    cards/
    (\d+)                    # card number
  }ix

  queue_as :default

  def perform(repo:, pr_number:, pr_body:)
    close_directly_linked_cards(repo, pr_number)
    close_cards_referenced_in_body(pr_body)
  end

  private
    def close_directly_linked_cards(repo, pr_number)
      PullRequestLink.for_pr(repo, pr_number).open.find_each do |link|
        Current.with_account(link.account) do
          link.mark_merged!
        end
      end
    end

    def close_cards_referenced_in_body(body)
      return if body.blank?

      extract_card_references(body).each do |account, numbers|
        next unless account.github_integration&.active?

        Current.with_account(account) do
          numbers.each do |number|
            if card = account.cards.open.find_by(number: number)
              card.close(user: account.system_user)
            end
          end
        end
      end
    end

    def extract_card_references(text)
      references = {}

      text.scan(FIZZY_CARD_URL_PATTERN) do |slug, number|
        external_id = AccountSlug.decode(slug)
        if account = Account.find_by(external_account_id: external_id)
          references[account] ||= Set.new
          references[account] << number.to_i
        end
      end

      references.transform_values(&:to_a)
    end
end
