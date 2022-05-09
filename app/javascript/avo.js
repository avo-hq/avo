// eslint-disable-next-line import/no-extraneous-dependencies
import 'core-js/stable'
// eslint-disable-next-line import/no-extraneous-dependencies
import 'regenerator-runtime/runtime'
import * as ActiveStorage from '@rails/activestorage'
import * as Mousetrap from 'mousetrap'
import { Turbo } from '@hotwired/turbo-rails'
import Rails from '@rails/ujs'
import tippy from 'tippy.js'

import 'chartkick/chart.js/chart.esm'

// Toastr alerts
import './js/active-storage'
import './js/controllers'
import { reloadPage, restoreScrollTop } from './js/page_reloader'

Rails.start()

window.Turbolinks = Turbo

Mousetrap.bind('r r r', reloadPage)

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
      reference.removeAttribute('data-tippy')

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

  console.log(1, restoreScrollTop())

  // Restore scroll position after r r r turbo reload
  // if (scrollTop) {
  //   setTimeout(() => {
  //     document.scrollingElement.scrollTo(0, scrollTop)
  //     scrollTop = 0
  //   }, 50)
  // }
})

document.addEventListener('turbo:frame-load', () => {
  initTippy()
})

document.addEventListener('turbo:before-fetch-response', async (e) => {
  if (e.detail.fetchResponse.response.status === 500) {
    const { id, src } = e.target
    e.target.src = `${window.Avo.configuration.root_path}/failed_to_load?turbo_frame=${id}&src=${src}`
  }
})

document.addEventListener('turbo:visit', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-start', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-end', () => document.body.classList.remove('turbo-loading'))
document.addEventListener('turbo:before-cache', () => {
  document
    .querySelectorAll('[data-turbo-remove-before-cache]')
    .forEach((element) => element.remove())
})

window.Avo = window.Avo || { configuration: {} }

// eslint-disable-next-line import/first
import './action_cable'

window.Avo.menus = {
  resetCollapsedState() {
    Array.from(document.querySelectorAll('[data-menu-key-param]'))
      .map((i) => i.getAttribute('data-menu-key-param'))
      .filter(Boolean)
      .forEach((key) => {
        window.localStorage.removeItem(key)
      })
  },
}

// // app/javascript/channels/appearance_channel.js
// import consumer from "./consumer"

// consumer.subscriptions.create({ channel: "AppearanceChannel" })
