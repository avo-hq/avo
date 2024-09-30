// eslint-disable-next-line import/no-extraneous-dependencies
import 'core-js/stable'
// eslint-disable-next-line import/no-extraneous-dependencies
import 'chartkick/chart.js/chart.esm'
import 'mapkick/bundle'
import 'regenerator-runtime/runtime'
import * as ActiveStorage from '@rails/activestorage'
import * as Mousetrap from 'mousetrap'
import { Turbo } from '@hotwired/turbo-rails'
import tippy from 'tippy.js'

import { LocalStorageService } from './js/local-storage-service'

import './js/active-storage'
import './js/controllers'
import './js/custom-confirm'
import './js/custom-stream-actions'

window.Avo.localStorage = new LocalStorageService()

window.Turbolinks = Turbo

let scrollTop = null
Mousetrap.bind('r r r', () => {
  // Cpture scroll position
  scrollTop = document.scrollingElement.scrollTop

  Turbo.visit(window.location.href, { action: 'replace' })
})

function isMac() {
  const isMac = window.navigator.userAgent.indexOf('Mac OS X')

  if (isMac >= 0) {
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

      // Identify elements that have tippy tooltip with the has-data-tippy attribute
      // Store the title on the attribute
      // Used to revert data-tippy and title attributes before cache
      reference.setAttribute('has-data-tippy', title)

      return title
    },
    onShow(tooltipInstance) {
      // Don't render tooltip if there is no content.
      if (tooltipInstance.props.content === null || tooltipInstance.props.content.length === 0) {
        return false
      }

      return tooltipInstance
    },
  })
}

window.initTippy = initTippy

ActiveStorage.start()

document.addEventListener('turbo:load', () => {
  initTippy()
  isMac()

  // Restore scroll position after r r r turbo reload
  if (scrollTop) {
    setTimeout(() => {
      document.scrollingElement.scrollTo(0, scrollTop)
      scrollTop = 0
    }, 50)
  }
  setTimeout(() => {
    document.body.classList.remove('turbo-loading')
  }, 1)
})

document.addEventListener('turbo:frame-load', () => {
  initTippy()

  // Handles turbo bug with lazy loading
  // https://github.com/hotwired/turbo/issues/886
  // Remove when PR https://github.com/hotwired/turbo/pull/1227 is merged
  document
    .querySelectorAll('turbo-frame[loading="lazy"][complete]')
    .forEach((frame) => frame.removeAttribute('loading'))
})

document.addEventListener('turbo:before-fetch-response', async (e) => {
  if (e.detail.fetchResponse.response.status === 500) {
    const { id, src } = e.target
    // Don't try to redirect to failed to load if this is alread a redirection to failed to load and crashed somewhere.
    // You'll end up with a request loop.
    if (!e.detail.fetchResponse?.response?.url?.includes('/failed_to_load')) {
      e.target.src = `${window.Avo.configuration.root_path}/failed_to_load?turbo_frame=${id}&src=${src}`
    }
  }
})

document.addEventListener('turbo:visit', () => {
  document.body.classList.add('turbo-loading')
})
document.addEventListener('turbo:submit-start', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-end', () => document.body.classList.remove('turbo-loading'))
document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('[data-turbo-remove-before-cache]').forEach((element) => element.remove())

  // Revert data-tippy and title attributes stored on the has-data-tippy attribute
  document.querySelectorAll('[has-data-tippy]').forEach((element) => {
    element.setAttribute('data-tippy', 'tooltip')
    element.setAttribute('title', element.getAttribute('has-data-tippy'))
    element.removeAttribute('has-data-tippy')
  })
})

window.Avo = window.Avo || { configuration: {} }

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
