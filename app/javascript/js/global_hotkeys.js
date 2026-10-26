/**
 * Global (non-element) keyboard shortcuts. Each entry names a registry ID from Avo::Hotkeys; the
 * key itself comes from config.hotkeys[:bindings].
 *
 * Two registries:
 *   - ELEMENT_HOTKEYS: handled via @github/hotkey
 *   - DIRECT_HOTKEYS: keydown listeners that need a condition (a page element, no open modal)
 */

import { install } from '@github/hotkey'
import { isUnderStackedModal } from './helpers/modal_stack'
import { isTypingTarget, keyFor, matches, matchesHotkey } from './hotkeys'

const RESOURCE_SEARCH_INPUT_SELECTOR = '[data-resource-search-target="input"]'
const findResourceSearchInput = () => document.querySelector(RESOURCE_SEARCH_INPUT_SELECTOR)

const RESOURCE_TABLE_SELECTOR = '[data-index-row-navigator-target="table"]'
const findResourceTable = () => document.querySelector(RESOURCE_TABLE_SELECTOR)

// The resource's index path is exposed via a <meta> tag only on show/edit pages,
// letting the go-to-index hotkey return to the listing from a single record.
const findMetaPath = (name) => document.querySelector(`meta[name="${name}"]`)?.getAttribute('content') || null
const findResourcesIndexPath = () => findMetaPath('avo:resources-index-path')

// Same idea for the create hotkey: show pages have no create button to hang a data-hotkey on, so the
// layout names the new path here — and only when the user is allowed to create.
const findResourcesNewPath = () => findMetaPath('avo:resources-new-path')

const visit = (path) => {
  if (window.Turbo) {
    window.Turbo.visit(path)
  } else {
    window.location.assign(path)
  }
}

// The content-focus point is the entry into each screen's main content: the
// index table, the grid wrapper, or a show/edit panel body. Focusing it lets the
// user immediately Tab into the content (and Shift+Tab back to the page controls).
const CONTENT_FOCUS_SELECTOR = '[data-content-focus]'

// Tabbed show/edit views render every panel with data-content-focus, but inactive
// tab panels stay in the DOM with a hidden class. Skip those so the focus hotkey lands on
// the content the user is actually viewing.
const isVisibleContentFocus = (element) => {
  if (!element) return false
  if (element.closest('[hidden], .hidden')) return false

  return element.getClientRects().length > 0
}

const isModalOpen = () => document.body.classList.contains('modal-open')

const findContentFocus = () => {
  // Show/edit panel bodies stay in the layout behind open modals (e.g. attach
  // media). Without this guard, the focus hotkey would focus obscured page content.
  if (isModalOpen()) return null

  return Array.from(document.querySelectorAll(CONTENT_FOCUS_SELECTOR)).find(isVisibleContentFocus) ?? null
}

// Find any mounted appearance Stimulus controller and call `method` on it.
// Multiple appearance switchers can be on the page (inline + dropdown fallback);
// either works since they share state via DOM classes + cookies/database.
function callAppearance(method) {
  const el = document.querySelector('[data-controller~="appearance"]')
  if (!el) return
  const controller = window.Stimulus?.getControllerForElementAndIdentifier(el, 'appearance')
  controller?.[method]?.()
}

// Use @github/hotkey for shortcuts with no page condition.
const ELEMENT_HOTKEYS = [
  {
    id: 'navigation.reload',
    handle: () => {
      window.reloadScrollTop = document.querySelector('.scrollable-wrapper')?.scrollTop
      window.StreamActions.turbo_reload()
    },
  },
]

// Direct listeners, matched by ./hotkeys so overrides, aliases and sequences apply here too.
const DIRECT_HOTKEYS = [
  {
    // Toggle the keyboard shortcuts modal.
    match: (e) => matches(e, 'shortcuts.toggle'),
    handle: () => document.dispatchEvent(new Event('persistent-modal:toggle')),
  },
  {
    // Focus the resource search input on index pages.
    match: (e) => matches(e, 'index.focus_search') && !!findResourceSearchInput(),
    handle: () => {
      const input = findResourceSearchInput()
      if (input) input.focus()
    },
  },
  {
    // Return to the resource's index page (from a show/edit page).
    match: (e) => matches(e, 'resource.go_to_index') && !isModalOpen() && !!findResourcesIndexPath(),
    handle: () => visit(findResourcesIndexPath()),
  },
  {
    // The resource's new page (from a show page). On an index the create button's own data-hotkey
    // handles the same key; the meta tag is absent there, so the two never both fire.
    match: (e) => matches(e, 'resource.new') && !isModalOpen() && !!findResourcesNewPath(),
    handle: () => visit(findResourcesNewPath()),
  },
  {
    // Cycle appearance scheme (auto → light → dark → …)
    match: (e) => matches(e, 'appearance.cycle_scheme'),
    handle: () => callAppearance('cycleScheme'),
  },
  {
    // Cycle neutral theme (brand → slate → stone → …)
    match: (e) => matches(e, 'appearance.cycle_neutral'),
    handle: () => callAppearance('cycleNeutral'),
  },
  {
    // Cycle accent color (brand → red → orange → …)
    match: (e) => matches(e, 'appearance.cycle_accent'),
    handle: () => callAppearance('cycleAccent'),
  },
  {
    // Toggle the appearance sound
    match: (e) => matches(e, 'appearance.toggle_sound'),
    handle: () => callAppearance('toggleSound'),
  },
  {
    // Focus the screen's main content (table rows, grid cards, or panel
    // fields). From there, Tab dives in and Shift+Tab returns to the page controls.
    match: (e) => matches(e, 'navigation.focus_content') && !!findContentFocus(),
    handle: () => findContentFocus()?.focus({ preventScroll: true }),
  },
  {
    // Focus the resource table AND move to the next row (Gmail/GitHub style)
    match: (e) => matches(e, 'index.next_row') && !!findResourceTable(),
    handle: () => {
      findResourceTable()?.focus({ preventScroll: true })
      document.dispatchEvent(new CustomEvent('avo:advance-resource-table', { detail: { direction: 'next' } }))
    },
  },
  {
    // Focus the resource table AND move to the previous row
    match: (e) => matches(e, 'index.previous_row') && !!findResourceTable(),
    handle: () => {
      findResourceTable()?.focus({ preventScroll: true })
      document.dispatchEvent(new CustomEvent('avo:advance-resource-table', { detail: { direction: 'previous' } }))
    },
  },
  {
    // Toggle kbd badge visibility (only when developer config allows badges)
    match: (e) => matches(e, 'hotkeys.toggle_badges')
      && window.Avo?.configuration?.hotkeys?.showKeyBadges !== false,
    handle: () => {
      document.documentElement.classList.toggle('hotkeys-hide-badges')
      const hidden = document.documentElement.classList.contains('hotkeys-hide-badges')
      try {
        if (hidden) {
          localStorage.setItem('avo:hotkeys:hide_badges', '1')
        } else {
          localStorage.removeItem('avo:hotkeys:hide_badges')
        }
      } catch (e) {
        // localStorage unavailable (private browsing) — toggle works for current session only
      }
    },
  },
]


// hotkey-fire is dispatched with { cancelable: true } but NOT { bubbles: true },
// so it never reaches a document-level listener. Must be registered on each element.
function hotkeyFireHandler(event) {
  const el = event.currentTarget

  // Stale element left behind after a Turbo body replacement (e.g. clicking a
  // broken resource renders Rails' error page). @github/hotkey keeps its
  // reference, so without this guard pressing "p" would .click() the detached
  // sidebar link and navigate. Cancel so hotkeys are inert on non-Avo pages.
  if (!el.isConnected) {
    event.preventDefault()
    return
  }

  // A modal with a dialog stacked on it (a belongs_to "Create new") keeps its hotkeys quiet: Escape on
  // the stacked dialog must not also press the Cancel button of the modal underneath.
  if (isUnderStackedModal(el)) {
    event.preventDefault()

    return
  }

  const hotkey = el.getAttribute('data-hotkey')

  // Apply feedback to ALL elements sharing this hotkey (e.g. desktop + mobile sidebar).
  // @github/hotkey fires on the last-registered element which may be hidden.
  const kbds = hotkey
    ? document.querySelectorAll(`[data-hotkey="${CSS.escape(hotkey)}"] kbd`)
    : el.querySelectorAll('kbd')

  if (!kbds.length) return

  event.preventDefault()
  kbds.forEach((kbd) => {
    kbd.classList.add('kbd--called')
    kbd.addEventListener('transitionend', () => kbd.classList.remove('kbd--called'), { once: true })
  })
  // Double rAF: the first fires before paint (style committed), the second
  // fires after the browser has actually painted the kbd--called state.
  requestAnimationFrame(() => {
    requestAnimationFrame(() => el.click())
  })
}

export function attachHotkeyFeedback(el) {
  el.removeEventListener('hotkey-fire', hotkeyFireHandler)
  el.addEventListener('hotkey-fire', hotkeyFireHandler)
}

export function installGlobalHotkeys() {
  if (window.Avo?.configuration?.hotkeys?.enabled === false) return

  document.addEventListener('turbo:load', () => {
    document.querySelectorAll('kbd.kbd--called').forEach((kbd) => kbd.classList.remove('kbd--called'))

    if (window.reloadScrollTop) {
      setTimeout(() => {
        document.querySelector('.scrollable-wrapper')?.scrollTo(0, window.reloadScrollTop)
        window.reloadScrollTop = null
      }, 50)
    }
  })

  ELEMENT_HOTKEYS.forEach(({ id, handle }) => {
    const hotkey = keyFor(id)
    if (!hotkey) return

    const el = document.createElement('span')
    el.addEventListener('hotkey-fire', (event) => {
      event.preventDefault()
      handle()
    })
    install(el, hotkey)
  })

  document.addEventListener('keydown', (event) => {
    if (event.defaultPrevented || event.repeat) return

    const entry = DIRECT_HOTKEYS.find(({ match }) => match(event))
    if (entry) {
      event.preventDefault()
      entry.handle()
    }
  })

  // @github/hotkey keeps data-hotkey elements quiet while a field has focus. The matcher lets a chord with
  // a modifier reach fields everywhere else, so fire the element here in that one case; a bare key still
  // fails the matcher. Last visible match wins, as the library picks its last-registered element.
  document.addEventListener('keydown', (event) => {
    if (event.defaultPrevented || event.repeat || !isTypingTarget(event)) return

    const el = Array.from(document.querySelectorAll('[data-hotkey]'))
      .filter((candidate) => candidate.getClientRects().length && matchesHotkey(event, candidate.getAttribute('data-hotkey')))
      .at(-1)
    if (!el) return

    event.preventDefault()
    el.dispatchEvent(new CustomEvent('hotkey-fire', { cancelable: true }))
  })
}
