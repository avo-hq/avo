// eslint-disable-next-line import/no-extraneous-dependencies
import 'core-js/stable'
// eslint-disable-next-line import/no-extraneous-dependencies
import 'regenerator-runtime/runtime'
import * as ActiveStorage from '@rails/activestorage'
import * as Mousetrap from 'mousetrap'
import { Turbo } from '@hotwired/turbo-rails'
import tippy from 'tippy.js'

import { LocalStorageService } from './js/local-storage-service'

import './js/active-storage'
import './js/controllers'
import './js/custom-stream-actions'
import 'chartkick/chart.js/chart.esm'
import 'mapkick/bundle'

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

      return title
    },
  })
}

// Detect whether an element is in view inside a parent element.
// Original here: https://gist.github.com/jjmu15/8646226
function isInViewport(element, parentElement) {
  const rect = element.getBoundingClientRect()
  const html = document.documentElement
  const parent = parentElement.getBoundingClientRect()

  return (
    rect.top >= 0
    && rect.left >= 0
    && rect.bottom <= (parent.height || window.innerHeight || html.clientHeight)
    && rect.right <= (parent.width || window.innerWidth || html.clientWidth)
  )
}

// Used on initial page load to scroll to the first active sidebar item if it's not in view.
function scrollSidebarMenuItemIntoView() {
  if (!isInViewport(document.querySelector('.avo-sidebar .mac-styled-scrollbar a.active'), document.querySelector('.avo-sidebar .mac-styled-scrollbar'))) {
    document.querySelector('.avo-sidebar .mac-styled-scrollbar a.active').scrollIntoView({ block: 'end', inline: 'nearest' })
  }
}

window.initTippy = initTippy

ActiveStorage.start()

let sidebarScrollPosition = null

document.addEventListener('turbo:load', () => {
  initTippy()
  isMac()
  if (window.Avo.configuration.focus_sidebar_menu_item) {
    scrollSidebarMenuItemIntoView()
  }

  // Restore sidebar scroll position
  if (sidebarScrollPosition && window.Avo.configuration.preserve_sidebar_scroll) {
    document.querySelector('.avo-sidebar .mac-styled-scrollbar').scrollTo({
      top: sidebarScrollPosition,
      behavior: 'instant',
    })
  }

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
  // Remeber sidebar scroll position before changing pages.
  sidebarScrollPosition = document.querySelector('.avo-sidebar .mac-styled-scrollbar').scrollTop

  document.body.classList.add('turbo-loading')
})
document.addEventListener('turbo:submit-start', () => document.body.classList.add('turbo-loading'))
document.addEventListener('turbo:submit-end', () => document.body.classList.remove('turbo-loading'))
document.addEventListener('turbo:before-cache', () => {
  document.querySelectorAll('[data-turbo-remove-before-cache]').forEach((element) => element.remove())
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
