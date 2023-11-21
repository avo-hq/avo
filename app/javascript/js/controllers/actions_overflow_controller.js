import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['content']

  static values = {
    panelList: Boolean,
  }

  // get the table or grid component, if both null, get the panel body (for show page for example)
  get parentTarget() {
    return document.querySelector('[data-component-name="avo/index/resource_table_component"]')
      || document.querySelector('[data-component-name="avo/index/resource_grid_component"]')
      || document.querySelector('[data-target="panel-body"]')
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
    if (this.contentLeftOverflow) {
      this.contentTarget.classList.remove('xl:right-0', 'sm:right-0')
      this.contentTarget.classList.add('xl:left-0', 'sm:left-0')
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
}
