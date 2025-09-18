import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="stars-field"
export default class extends Controller {
  static targets = ["valueInput", "starsContainer", "star"]

  connect() {
    this.maxValue = parseInt(this.starsContainerTarget.dataset.max)
    this.currentValue = parseInt(this.starsContainerTarget.dataset.currentValue)
    this.updateStarsDisplay(this.currentValue)
  }

  setStar(event) {
    const starValue = parseInt(event.currentTarget.dataset.starValue)

    // If clicking the same star that's already selected, set to 0 (no rating)
    if (starValue === this.currentValue) {
      this.currentValue = 0
    } else {
      this.currentValue = starValue
    }

    // Update the hidden input value
    this.valueInputTarget.value = this.currentValue

    // Update the visual display
    this.updateStarsDisplay(this.currentValue)

    // Trigger change event for form validation
    this.valueInputTarget.dispatchEvent(new Event('change'))
  }

  hoverStar(event) {
    const hoverValue = parseInt(event.currentTarget.dataset.starValue)
    this.updateStarsDisplay(hoverValue, true)
  }

  unhoverStar(event) {
    // Return to the actual selected value when not hovering
    this.updateStarsDisplay(this.currentValue)
  }

  updateStarsDisplay(value, isHover = false) {
    this.starTargets.forEach((star, index) => {
      const starValue = index + 1

      // Add appropriate class based on value
      if (starValue <= value) {
        star.classList.add('filled')
      } else {
        star.classList.remove('filled')
      }
    })
  }
}