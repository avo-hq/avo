import { Turbo } from '@hotwired/turbo-rails'

window.scrollTop ||= null

const restoreScrollTop = () => {
  // document.addEventListener('turbo:load', () => {
  console.log('scrollTop->', window.scrollTop)
  // Restore scroll position after r r r turbo reload
  if (window.scrollTop) {
    setTimeout(() => {
      console.log('window.scrollTop in settimeout->', window.scrollTop)
      document.scrollingElement.scrollTo(0, 100)
      // window.scrollTop = null
    }, 50)
  }
  // })
}

const reloadPage = () => {
  console.log('reloadPage->', window.scrollTop)
  // Cpture scroll position
  window.scrollTop = document.scrollingElement.scrollTop
  console.log('reloadPage2->', window.scrollTop)

  Turbo.visit(window.location.href, { action: 'replace' })
}

export { reloadPage, restoreScrollTop }
