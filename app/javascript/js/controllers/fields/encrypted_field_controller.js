import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['value', 'button', 'showIcon', 'hideIcon']

  static values = {
    revealPath: String,
    revealed: { type: Boolean, default: false },
    maskedValue: { type: String, default: '••••••••' },
  }

  async toggle(event) {
    event.preventDefault()

    if (this.revealedValue) {
      this.hide()
    } else {
      await this.reveal()
    }
  }

  async reveal() {
    if (!this.hasRevealPathValue) return

    try {
      this.buttonTarget.disabled = true

      const response = await fetch(this.revealPathValue, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
        credentials: 'same-origin',
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      if (data.value !== undefined) {
        this.valueTarget.textContent = data.value || '(empty)'
        this.revealedValue = true
        this.updateIcons()
      }
    } catch (error) {
      console.error('Failed to reveal encrypted value:', error)
      this.valueTarget.textContent = 'Error loading value'
    } finally {
      this.buttonTarget.disabled = false
    }
  }

  hide() {
    this.valueTarget.textContent = this.maskedValueValue
    this.revealedValue = false
    this.updateIcons()
  }

  updateIcons() {
    if (this.hasShowIconTarget && this.hasHideIconTarget) {
      if (this.revealedValue) {
        this.showIconTarget.classList.add('hidden')
        this.hideIconTarget.classList.remove('hidden')
      } else {
        this.showIconTarget.classList.remove('hidden')
        this.hideIconTarget.classList.add('hidden')
      }
    }
  }
}
