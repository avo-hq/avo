import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['option']

  navigate(event) {
    if (!['ArrowDown', 'ArrowUp'].includes(event.key)) return
    event.preventDefault()

    const options = this.optionTargets
    const index = options.indexOf(document.activeElement)
    const next = event.key === 'ArrowDown'
      ? (index + 1) % options.length
      : (index - 1 + options.length) % options.length

    options[next]?.focus()
  }
}
