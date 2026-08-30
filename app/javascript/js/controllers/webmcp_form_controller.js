import { Controller } from '@hotwired/stimulus'

// Attached to a form that Avo::Concerns::FormBuilder announced as a WebMCP tool. The browser derives the
// tool's schema from the inputs, and `toolparamdescription` is the one thing it cannot derive — so each
// input gets its label, plus the field's help text when there is one, the way the form explains the
// field to a person. Inputs that already carry a description are left alone.
export default class extends Controller {
  connect() {
    this.element.querySelectorAll('input, select, textarea').forEach((control) => {
      if (control.type === 'hidden' || control.hasAttribute('toolparamdescription')) return

      const description = this.describe(control)

      if (description) control.setAttribute('toolparamdescription', description)
    })
  }

  describe(control) {
    const label = control.labels?.[0]?.textContent?.trim()
    const help = control.closest('.field-wrapper')?.querySelector('.field-wrapper__help')?.textContent?.trim()

    // Agents cap parameter descriptions around 150 characters; past that they truncate or drop them.
    return [label, help].filter(Boolean).join(' — ').slice(0, 150)
  }
}
