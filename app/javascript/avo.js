// eslint-disable-next-line import/no-extraneous-dependencies
import 'core-js/stable'
// eslint-disable-next-line import/no-extraneous-dependencies
import 'regenerator-runtime/runtime'
import * as ActiveStorage from '@rails/activestorage'
import * as Mousetrap from 'mousetrap'
import { Turbo } from '@hotwired/turbo-rails'
import Rails from '@rails/ujs'
import tippy from 'tippy.js'

// Toastr alerts
import './js/active-storage'
import './js/controllers'
import './js/toastr'

Rails.start()

window.Turbolinks = Turbo

Mousetrap.bind('r r r', () => Turbo.visit(window.location.href, { action: 'replace' }))

function isMac() {
  const isMac = window.navigator.userAgent.indexOf('Mac OS X')

  if (isMac) {
    document.body.classList.add('os-mac')
    document.body.classList.remove('os-pc')
  } else {
    document.body.classList.add('os-pc')
    document.body.classList.remove('os-mac')
  }
}
function initTippy() {
  tippy('[data-tippy="tooltip"]', {
    theme: 'light',
    content(reference) {
      const title = reference.getAttribute('title')
      reference.removeAttribute('title')

      return title
    },
  })
}
window.initTippy = initTippy

ActiveStorage.start()

document.addEventListener('turbo:load', () => {
  document.body.classList.remove('turbo-loading')
  initTippy()
  isMac()
})

document.addEventListener('turbo:before-fetch-response', (e) => {
  if (e.detail.fetchResponse.response.status === 500) {
    const id = e.srcElement.getAttribute('id')
    e.srcElement.src = `${window.Avo.configuration.root_path}/failed_to_load?turbo_frame=${id}`
  }
})
document.addEventListener('turbo:visit', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-start', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-end', () => document.body.classList.remove('turbo-loading'))
document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('[data-turbo-remove-before-cache]').forEach((element) => element.remove())
})
