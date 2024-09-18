class BoostsController < ApplicationController
  include BubbleScoped, ProjectScoped

  def index
  end

  def create
    @bubble.boosts.create!
  end
end
