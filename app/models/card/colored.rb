module Card::Colored
  extend ActiveSupport::Concern

  COLORS = %w[
    var(--color-card-1)
    var(--color-card-2)
    var(--color-card-3)
    var(--color-card-4)
    var(--color-card-5)
    var(--color-card-6)
    var(--color-card-7)
    var(--color-card-8)
  ]
  DEFAULT_COLOR = "var(--color-card-default)"

  def color
    color_from_stage || DEFAULT_COLOR
  end

  private
    def color_from_stage
      stage&.color&.presence if doing?
    end
end
