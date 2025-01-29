import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

export default class extends Controller {
  static targets = ['input']

  connect() {
    console.log('Resource search controller connected')
  }

  async search() {
    const query = this.inputTarget.value
    const currentUrl = new URL(window.location.href)
    currentUrl.searchParams.set('q', query)

    try {
      await get(currentUrl.pathname + currentUrl.search, {
        responseKind: 'turbo-stream'
      })
    } catch (error) {
      console.error('Error performing search:', error)
    }
  }
}
