import { Controller } from '@hotwired/stimulus'
import { registerTool } from '../webmcp'

// Declares one WebMCP tool from markup and answers it with a GET to `url`:
//
//   <div hidden data-controller="webmcp-tool"
//        data-webmcp-tool-url-value="/admin/avo_api/{resource}/search"
//        data-webmcp-tool-definition-value='{"name":"search_records","description":"…","inputSchema":{…}}'>
//
// `{param}` in the URL is filled from the tool's input; every other input goes on the query string. The
// tool exists while the element is connected — under Turbo, for the page that rendered it — so a
// page-specific tool is rendered on that page and nowhere else.
//
// ponytail: GET only, so the tool is read-only by construction. A tool that writes is a form (the
// declarative API covers it) or registers through Avo.webmcp.registerTool with its own execute.
export default class extends Controller {
  static values = { definition: Object, url: String }

  connect() {
    this.abortController = new AbortController()

    registerTool(
      { ...this.definitionValue, execute: (inputs, options) => this.fetch(inputs, options) },
      { signal: this.abortController.signal },
    )
  }

  disconnect() {
    this.abortController?.abort()
  }

  async fetch(inputs = {}, { signal } = {}) {
    const remaining = { ...inputs }
    const path = this.urlValue.replace(/\{(\w+)\}/g, (_, key) => {
      const value = remaining[key]
      delete remaining[key]

      return encodeURIComponent(value ?? '')
    })
    const url = new URL(path, window.location.origin)

    Object.entries(remaining).forEach(([key, value]) => {
      if (value != null) url.searchParams.set(key, value)
    })

    const response = await fetch(url, {
      headers: { Accept: 'application/json' },
      credentials: 'same-origin',
      signal,
    })

    if (!response.ok) return `Request failed with HTTP ${response.status}.`

    return response.text()
  }
}
