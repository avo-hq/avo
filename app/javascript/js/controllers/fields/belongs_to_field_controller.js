import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['select', 'type', 'loadAssociationLink'];

  defaults = {};

  get selectedType() {
    return this.selectTarget.value
  }

  get isSearchable() {
    return this.context.scope.element.dataset.searchable === 'true'
  }

  get association() {
    return this.context.scope.element.dataset.association
  }

  get associationClass() {
    return this.context.scope.element.dataset.associationClass
  }

  connect() {
    this.copyValidNames()
    this.changeType() // Do the initial type change
  }

  changeType() {
    this.hideAllTypes()
    this.showType(this.selectTarget.value)
  }

  // Private

  hideAllTypes() {
    this.typeTargets.forEach((target) => {
      target.classList.add('hidden')

      this.invalidateTarget(target)
    })
  }

  /**
   * Used for invalidating select fields when switching between types so they don't automatically override the previous id.
   * Ex: There are two types Article and Project and the Comment has commentable_id 3 and commentable_type: Article
   * When you change the type from Project to Article the Project field will override the commentable_id value
   * because it was rendered later (alphabetical sorting) and the browser will pick that one up.
   * So we go and copy the name attribute to valid-name for all types and then copy it back to name when the user selects it.
   */

  /**
   * This method does the initial copying from name to valid-name.
   */
  copyValidNames() {
    this.typeTargets.forEach((target) => {
      const { type } = target.dataset

      if (this.isSearchable) {
        const textInput = target.querySelector('input[type="text"]')
        if (textInput) this.nameToValidName(textInput)

        const hiddenInput = target.querySelector('input[type="hidden"]')
        if (hiddenInput) this.nameToValidName(hiddenInput)
      } else {
        const select = target.querySelector('select')
        if (select) this.nameToValidName(select)

        const hiddenInput = target.querySelector('input[type="hidden"]')
        if (hiddenInput) this.nameToValidName(hiddenInput)

        if (this.selectedType !== type) {
          select.selectedIndex = 0
        }
      }
    })
  }

  showType(type) {
    const target = this.typeTargets.find(
      (typeTarget) => typeTarget.dataset.type === type,
    )
    if (target) {
      target.classList.remove('hidden')

      this.validateTarget(target)
    }
  }

  /**
   * Copy value from `valid-name` to `name`
   */
  validateTarget(target) {
    if (this.isSearchable) {
      const textInput = target.querySelector('input[type="text"]')
      const hiddenInput = target.querySelector('input[type="hidden"]')

      this.validNameToName(textInput)
      this.validNameToName(hiddenInput)
    } else {
      const select = target.querySelector('select')
      const hiddenInput = target.querySelector('input[type="hidden"]')
      this.validNameToName(select)

      if (hiddenInput) {
        this.validNameToName(hiddenInput)
      }
    }
  }

  /**
   * nullify the `name` attribute
   */
  invalidateTarget(target) {
    if (this.isSearchable) {
      // Wrapping it in a try/catch to counter turbo's cache system (going back to the edit page after initial save)
      try {
        target.querySelector('input[type="text"]').setAttribute('name', '')
        target.querySelector('input[type="hidden"]').setAttribute('name', '')
      } catch {}
    } else if (target) {
      try {
        target.querySelector('select').setAttribute('name', '')
        target.querySelector('input[type="hidden"]').setAttribute('name', '')
      } catch (error) {}
    }
  }

  validNameToName(target) {
    target.setAttribute('name', target.getAttribute('valid-name'))
  }

  nameToValidName(target) {
    target.setAttribute('valid-name', target.getAttribute('name'))
  }
}
