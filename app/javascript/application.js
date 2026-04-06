// eslint-disable-next-line import/no-extraneous-dependencies
import 'core-js/stable'
// eslint-disable-next-line import/no-extraneous-dependencies
import 'chartkick/chart.js/chart.esm'
import Mapkick from 'mapkick'
import mapboxgl from 'mapbox-gl'
import 'regenerator-runtime/runtime'
import * as ActiveStorage from '@rails/activestorage'
import { Turbo } from '@hotwired/turbo-rails'
import { install } from '@github/hotkey'
import tippy from 'tippy.js'

import { LocalStorageService } from './js/local-storage-service'
import { attachHotkeyFeedback, installGlobalHotkeys } from './js/global_hotkeys'

import './js/active-storage'
import './js/controllers'
import './js/custom-confirm'
import './js/custom-stream-actions'

function installHotkeys(root = document) {
  root.querySelectorAll('[data-hotkey]').forEach((el) => {
    install(el)
    attachHotkeyFeedback(el)
  })
}

Mapkick.use(mapboxgl)

window.Avo.localStorage = new LocalStorageService()

window.Turbolinks = Turbo

installGlobalHotkeys()

function initTippy() {
  tippy('[data-tippy="tooltip"]', {
    theme: 'basic',
    allowHTML: true,
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

document.addEventListener('turbo:before-stream-render', () => {
  // We're using the timeout feature so we can fake the `turbo:after-stream-render` event
  setTimeout(() => {
    initTippy()
  }, 1)
})

document.addEventListener('turbo:frame-render', (e) => {
  if (window.Avo?.configuration?.hotkeys?.enabled !== false) installHotkeys(e.target)
})

document.addEventListener('turbo:load', () => {
  // Restore badge visibility preference from localStorage before installing hotkeys
  if (window.Avo?.configuration?.hotkeys?.showKeyBadges !== false) {
    try {
      if (localStorage.getItem('avo:hotkeys:hide_badges') === '1') {
        document.body.classList.add('hotkeys-hide-badges')
      } else {
        document.body.classList.remove('hotkeys-hide-badges')
      }
    } catch (e) {
      // localStorage unavailable
    }
  }

  if (window.Avo?.configuration?.hotkeys?.enabled !== false) installHotkeys()
  initTippy()

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
    // Don't try to redirect to failed to load if this is already a redirection to failed to load and crashed somewhere.
    // You'll end up with a request loop.
    if (!e.detail.fetchResponse?.response?.url?.includes('/failed_to_load')) {
      e.target.removeAttribute('loading')

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

// Watch for live changes when the user has "auto" as the default setting.
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (event) => {
  const method = event.matches ? 'add' : 'remove'

  document.documentElement.classList[method]('dark')
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
