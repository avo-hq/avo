import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content']

  static values = {
    panelList: Boolean,
  }

  // Table/grid on index pages; main content region on show/edit and other non-list views.
  get parentTarget() {
    return document.querySelector('[data-component-name="avo/view_types/table_component"]')
      || document.querySelector('[data-component-name="avo/view_types/grid_component"]')
      || document.querySelector('#main-content')
  }

  // Parent nodes grow with page content, but overflow should be measured against
  // the visible viewport — the old .scrollable-wrapper had a fixed height for this.
  get visibleParentDimensions() {
    const parent = this.parentTarget

    if (!parent) {
      return { top: 0, left: 0, right: window.innerWidth, bottom: window.innerHeight }
    }

    const rect = parent.getBoundingClientRect()

    return {
      top: rect.top,
      left: rect.left,
      right: rect.right,
      bottom: Math.min(rect.bottom, window.innerHeight),
    }
  }

  // Check if the document is in RTL mode
  get isRTL() {
    return document.documentElement.dir === 'rtl'
  }

  childDimensions = null

  parentDimensions = null

  connect() {
    // We need to make the element visible in order to get it's position
    this.element.style.display = 'block'
    this.childDimensions = this.contentTarget.getBoundingClientRect()
    this.element.style.display = ''
    this.parentDimensions = this.visibleParentDimensions

    this.adjustOverflow()
  }

  adjustOverflow() {
    this.adjustVerticalOverflow()
    this.adjustHorizontalOverflow()
  }

  adjustVerticalOverflow() {
    if (this.contentBottomOverflow) {
      this.contentTarget.classList.remove('top-full', 'mt-2')
      this.contentTarget.classList.add('bottom-full', 'mb-2')
    }
  }

  adjustHorizontalOverflow() {
    if (this.isRTL) {
      // RTL: Check for right overflow and flip to left if needed
      if (this.contentRightOverflow) {
        this.contentTarget.classList.remove('xl:start-0', 'sm:start-0')
        this.contentTarget.classList.add('xl:end-0', 'sm:end-0')
      }
    } else if (this.contentLeftOverflow) {
      this.contentTarget.classList.remove('xl:end-0', 'sm:end-0')
      this.contentTarget.classList.add('xl:start-0', 'sm:start-0')
    }
  }

  get contentBottomOverflow() {
    // If the list is on panel header, we don't want to adjust the vertical overflow
    if (this.panelListValue === true) {
      return false
    }

    return this.parentDimensions.bottom < this.childDimensions.bottom
  }

  get contentLeftOverflow() {
    return this.parentDimensions.left > this.childDimensions.left
  }

  get contentRightOverflow() {
    return this.parentDimensions.right < this.childDimensions.right
  }
}
