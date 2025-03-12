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
  }

  add(event) {
    super.add(event)

    if (this.limitValue > 0 && this.nestedRecordTargets.length >= this.limitValue) {
      this.addButtonTarget.classList.add('hidden')
    }
  }

  remove(event) {
    super.remove(event)

    if (this.limitValue > 0 && this.nestedRecordTargets.length < this.limitValue) {
      this.addButtonTarget.classList.remove('hidden')
    }
  }
}
