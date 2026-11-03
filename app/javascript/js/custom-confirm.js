import { Turbo } from '@hotwired/turbo-rails'

let dependentsRequest = 0

// Turbo hands over the form it built from a delete link, not the link, so find the link by the URL they share.
// The form moves the link's query string into hidden inputs, so only the paths are compared.
function dependentsUrlFor(form) {
  if (!form?.action) return null

  const path = new URL(form.action).pathname
  const link = [...document.querySelectorAll('[data-dependents-url]')].find((element) => new URL(element.href).pathname === path)

  return link?.dataset.dependentsUrl
}

async function showDependents(dialog, form) {
  const target = dialog.querySelector('[data-dependents]')
  target.hidden = true

  const url = dependentsUrlFor(form)
  if (!url) return

  target.textContent = target.dataset.loadingText
  target.classList.add('animate-pulse')
  target.hidden = false

  // A dialog reopened for another record while this request was in flight must not show its answer.
  dependentsRequest += 1
  const request = dependentsRequest
  let message = null
  try {
    const response = await fetch(url, { headers: { Accept: 'application/json' } })
    if (response.ok) ({ message } = await response.json())
  } catch {
    // The warning is extra information; a failed request leaves the plain confirmation.
  }
  if (request !== dependentsRequest) return

  target.classList.remove('animate-pulse')
  target.textContent = message || ''
  target.hidden = !message
}

Turbo.config.forms.confirm = (message, form) => {
  const dialog = document.getElementById('turbo-confirm')
  dialog.querySelector('p').textContent = message
  // The dialog keeps the answer it got last time, and closing it without choosing would repeat that answer.
  dialog.returnValue = ''
  dialog.showModal()
  showDependents(dialog, form)

  dialog.addEventListener('click', (event) => {
    if (event.target.nodeName === 'DIALOG') {
      dialog.close()
    }
  })

  return new Promise((resolve) => {
    dialog.addEventListener('close', () => {
      resolve(dialog.returnValue === 'confirm')
    }, { once: true })
  })
}
