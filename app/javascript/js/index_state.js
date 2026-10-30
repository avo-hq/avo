// Remembers what the user was doing on an index page (selected rows and scroll position) so it can
// be put back when they go back to it: with the browser's Back button, or with the "Go back" link on a
// record page. That link is a regular visit, so Turbo fetches a fresh page instead of restoring its
// snapshot. Any other way of reaching the page starts fresh, unless `config.persistence` keeps the selection:
// then every visit puts it back. State is kept per tab in sessionStorage and keyed by URL, so each
// combination of filters, sorting and page has its own.

const PREFIX = 'avo.index-state'

function selectionPersisted() {
  return window.Avo?.configuration?.persistence?.selection === true
}

let goBackClicked = false
let wentBack = false

document.addEventListener('turbo:click', (event) => {
  goBackClicked = event.target.matches('[data-go-back]')
})

// A "restore" visit is the browser's Back or Forward button.
document.addEventListener('turbo:visit', (event) => {
  wentBack = event.detail.action === 'restore' || goBackClicked
  goBackClicked = false
})

function read(key) {
  try {
    return window.sessionStorage.getItem(key)
  } catch {
    return null
  }
}

function write(key, value) {
  try {
    window.sessionStorage.setItem(key, value)
  } catch {
    // Storage can be full or blocked; losing the state is fine.
  }
}

function remove(key) {
  try {
    window.sessionStorage.removeItem(key)
  } catch {
    // Same as above.
  }
}

function urlKey(url) {
  const { pathname, search } = new URL(url, window.location.href)

  return `${pathname}${search}`
}

// A persisted selection has to survive the sidebar link, which carries none of the query params the sort and
// filter links do, so only the page tells its keys apart.
function selectionKey(resourceName, url) {
  if (selectionPersisted()) {
    const { pathname, searchParams } = new URL(url, window.location.href)

    return `${PREFIX}.selection.${resourceName}.${pathname}?page=${searchParams.get('page') || 1}`
  }

  return `${PREFIX}.selection.${resourceName}.${urlKey(url)}`
}

function scrollKey(url) {
  return `${PREFIX}.scroll.${urlKey(url)}`
}

// The rows to select again, handed out only when the user went back to the page. Any other visit forgets
// them, so a later "Go back" can't bring back a selection the user has since moved on from.
export function takeSelection(resourceName, url) {
  if (!wentBack && !selectionPersisted()) {
    remove(selectionKey(resourceName, url))

    return []
  }

  try {
    const ids = JSON.parse(read(selectionKey(resourceName, url)))

    return Array.isArray(ids) ? ids.map(String) : []
  } catch {
    return []
  }
}

export function setSelection(resourceName, url, ids) {
  if (ids.length > 0) {
    write(selectionKey(resourceName, url), JSON.stringify(ids))
  } else {
    remove(selectionKey(resourceName, url))
  }
}

// Forget every remembered selection for a resource, whatever page it was made on.
export function clearSelections(resourceName) {
  const prefix = `${PREFIX}.selection.${resourceName}.`

  try {
    Object.keys(window.sessionStorage)
      .filter((key) => key.startsWith(prefix))
      .forEach((key) => window.sessionStorage.removeItem(key))
  } catch {
    // Same as above.
  }
}

export function saveScroll(url, position) {
  write(scrollKey(url), String(position))
}

// The position is handed out once, and only when the user went back to the page.
export function takeScroll(url) {
  const key = scrollKey(url)
  const position = parseInt(read(key), 10)

  remove(key)

  return wentBack && !Number.isNaN(position) ? position : null
}
