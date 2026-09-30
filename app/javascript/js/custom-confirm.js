import { Turbo } from '@hotwired/turbo-rails'

Turbo.config.forms.confirm = (message) => {
  const dialog = document.getElementById('turbo-confirm')
  dialog.querySelector('p').textContent = message
  // The dialog keeps the answer it got last time, and closing it without choosing would repeat that answer.
  dialog.returnValue = ''
  dialog.showModal()

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
