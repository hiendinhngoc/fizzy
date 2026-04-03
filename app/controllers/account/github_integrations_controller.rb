class Account::GithubIntegrationsController < ApplicationController
  before_action :ensure_admin

  def show
    @github_integration = Current.account.github_integration
  end

  def create
    Current.account.create_github_integration!
    redirect_to account_github_integration_path, notice: "GitHub integration created"
  end

  def destroy
    Current.account.github_integration&.destroy
    redirect_to account_settings_path, notice: "GitHub integration removed"
  end
end
