export function toggleHidden(element) {
  if (element.hasAttribute('hidden')) {
    element.removeAttribute('hidden')
  } else {
    element.setAttribute('hidden', '')
  }
}
