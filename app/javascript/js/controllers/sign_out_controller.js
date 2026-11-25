import { Controller } from '@hotwired/stimulus'
import { destroy } from '@rails/request.js'
import { clearIndexState } from '../index_state'

export default class extends Controller {
  static targets = ['element']

  static values = {
    confirm: String,
  }

  // Turbo and the browser both keep pages to show again on Back, and a signed-out user must not get them.
  async handle(e) {
    e.preventDefault()

    // eslint-disable-next-line no-alert
    if (!window.confirm(this.confirmValue)) return

    window.Turbo.cache.clear()
    clearIndexState()

    // The browser keeps this page as it is when we leave, so it is left empty and loads again if it comes back.
    document.body.replaceChildren(this.element)
    this.element.hidden = true
    window.addEventListener('pageshow', (event) => {
      if (event.persisted) window.location.reload()
    })

    // Drops the pages opened before this one. Chrome answers only after clearing, so the wait has a limit.
    const siteDataPath = `${window.Avo.configuration.root_path}/site_data`
    await destroy(siteDataPath, { signal: AbortSignal.timeout(2000) }).catch(() => {})

    this.element.submit()
  }
}
