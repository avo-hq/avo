import { Controller } from '@hotwired/stimulus'

// Powers the internal color-token reference page (private#appearance): tab
// switching between token panels and click-to-copy on swatches, with a shared
// "Copied!" toast. Replaces the page's former inline <script> + onclick handlers
// so the page stays CSP-safe (no inline script execution).
export default class extends Controller {
  static targets = ['indicator']

  switchTab(event) {
    event.preventDefault()
    const button = event.currentTarget
    const group = button.closest('.tabs')
    const container = group.parentElement

    container.querySelectorAll('.tab-content').forEach((tab) => tab.classList.remove('active'))
    group.querySelectorAll('.tab-button').forEach((btn) => btn.classList.remove('active'))

    document.getElementById(button.dataset.tab)?.classList.add('active')
    button.classList.add('active')
  }

  copy(event) {
    const { copyText } = event.currentTarget.dataset
    if (!copyText) return

    navigator.clipboard.writeText(copyText).then(() => {
      if (!this.hasIndicatorTarget) return

      this.indicatorTarget.classList.add('show')
      setTimeout(() => this.indicatorTarget.classList.remove('show'), 2000)
    })
  }
}
