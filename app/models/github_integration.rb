class GithubIntegration < ApplicationRecord
  belongs_to :account

  has_secure_token :webhook_secret

  scope :active, -> { where(active: true) }

  def verify_signature(payload, signature)
    return false if signature.blank?

    expected = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', webhook_secret, payload)}"
    ActiveSupport::SecurityUtils.secure_compare(expected, signature)
  end

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end
end
