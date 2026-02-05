class Cards::PullRequestLinksController < ApplicationController
  include CardScoped

  before_action :set_pull_request_link, only: :destroy

  def create
    @card.link_pull_request(pull_request_link_params[:github_pr_url])

    respond_to do |format|
      format.turbo_stream { render_card_replacement }
      format.html { redirect_to @card }
      format.json { head :created }
    end
  end

  def destroy
    @card.unlink_pull_request(@pull_request_link)

    respond_to do |format|
      format.turbo_stream { render_card_replacement }
      format.html { redirect_to @card }
      format.json { head :no_content }
    end
  end

  private
    def set_pull_request_link
      @pull_request_link = @card.pull_request_links.find(params[:id])
    end

    def pull_request_link_params
      params.expect(pull_request_link: [ :github_pr_url ])
    end
end
