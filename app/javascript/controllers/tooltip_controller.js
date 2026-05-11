import { Controller } from "@hotwired/stimulus"
import { orient } from "helpers/orientation_helpers"

export default class extends Controller {
  static targets = [ "tooltip" ]

  connect() {
    this.mouseEnterListener = this.mouseEnter.bind(this)
    this.mouseOutListener = this.mouseOut.bind(this)

    this.element.addEventListener("mouseenter", this.mouseEnterListener)
    this.element.addEventListener("mouseout", this.mouseOutListener)
  }

  disconnect() {
    this.element.removeEventListener("mouseenter", this.mouseEnterListener)
    this.element.removeEventListener("mouseout", this.mouseOutListener)
  }

  mouseEnter() {
    if (!this.hasTooltipElement) return

    orient({ target: this.tooltipElement, anchor: this.element })
  }

  mouseOut() {
    if (!this.hasTooltipElement) return

    orient({ target: this.tooltipElement, reset: true })
  }

  get hasTooltipElement() {
    return !!this.tooltipElement
  }

  get tooltipElement() {
    return this.hasTooltipTarget ? this.tooltipTarget : this.element.querySelector(".for-screen-reader")
  }
}
