import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  computed: {
    canAttachResources() {
      return this.hasManyThrough || this.relationship === 'has_and_belongs_to_many'
    },
    relationship() {
      if (this.field && this.field.relationship) return this.field.relationship

      return null
    },
    hasManyThrough() {
      return this.relationship && this.relationship === 'has_many' && !isUndefined(this.field.through) && !isNull(this.field.through) && this.field.through !== ''
    },
    resourcePath() {
      if (this.resource && this.resource.path) {
        return this.resource.path
      }

      if (this.field && this.field.path) {
        return this.field.path
      }

      if (this.hasManyThrough) {
        return this.field.path
      }

      return this.resourceName.toLowerCase()
    },
  },
}
