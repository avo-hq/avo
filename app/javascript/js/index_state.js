// Remembers what the user was doing on an index page (selected rows and scroll position) so it can
// be put back when they return to it, for example through the "Go back" button on a record page.
// That button is a regular visit, so Turbo fetches a fresh page instead of restoring its snapshot.
// State is kept per tab in sessionStorage and keyed by URL, so each combination of filters, sorting
// and page has its own.

const PREFIX = 'avo.index-state'

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

function selectionKey(resourceName, url) {
  return `${PREFIX}.selection.${resourceName}.${urlKey(url)}`
}

function scrollKey(url) {
  return `${PREFIX}.scroll.${urlKey(url)}`
}

export function getSelection(resourceName, url) {
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

// The position is handed out once so later visits to the same URL start at the top as usual.
export function takeScroll(url) {
  const key = scrollKey(url)
  const position = parseInt(read(key), 10)

  remove(key)

  return Number.isNaN(position) ? null : position
}
