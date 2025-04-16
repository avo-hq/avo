import { Turbo } from '@hotwired/turbo-rails'

Turbo.config.forms.confirm = (message) => {
  const dialog = document.getElementById('turbo-confirm')
  dialog.querySelector('p').textContent = message
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
