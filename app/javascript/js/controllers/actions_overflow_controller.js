import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content']

  static values = {
    panelList: Boolean,
  }

  // get the table or grid component, if both null, get the panel body (for show page for example)
  get parentTarget() {
    return document.querySelector('[data-component-name="avo/view_types/table_component"]')
      || document.querySelector('[data-component-name="avo/view_types/grid_component"]')
      || document.querySelector('.main-content-area .scrollable-wrapper') // TODO: to be fixed when we get to the row controls
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
    this.parentDimensions = this.parentTarget.getBoundingClientRect()

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
