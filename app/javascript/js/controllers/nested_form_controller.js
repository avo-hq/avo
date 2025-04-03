import NestedForm from 'stimulus-rails-nested-form'

export default class extends NestedForm {
  static targets = [
    'addButton',
    'removeButton',
    'nestedRecord',
  ]

  static values = {
    // `limit` restricts `has_one` to a single nested record or allows unlimited nesting.
    // This could easily be extended into a configurable field option, allowing developers
    // to specify a custom limit for nested records during creation.
    // Default is 0 which is considered unlimited
    limit: Number,
    confirmMessage: String,
  }

  add(event) {
    super.add(event)
    this.toggleAddButton()
  }

  remove(event) {
    if (confirm(this.confirmMessageValue)) {
      super.remove(event)
      this.toggleAddButton()
    }
  }

  toggleAddButton() {
    if (this.limitValue > 0) {
      this.addButtonTarget.classList.toggle('hidden', this.nestedRecordTargets.length >= this.limitValue)
    }
  }
}
