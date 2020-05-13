import isNull from 'lodash/isNull'
import pluralize from 'pluralize'

export default {
  data: () => ({
    errors: {},
  }),
  computed: {
    resourceNameSingular() {
      return pluralize(this.resourceName, 1)
    },
    fields() {
      if (!this.resource || !this.resource.fields || this.resource.fields.length === 0) {
        return []
      }

      return this.resource
        .fields
        .filter((field) => field.updatable)
        .filter((field) => !field.computed)
    },
  },
  methods: {
    buildFormData() {
      const form = new FormData()

      this.resource
        .fields
        .filter((field) => field.updatable)
        .filter((field) => !field.computed)
        .map((field) => [field, isNull(field.getValue()) ? '' : field.getValue()])
        .forEach(([field, value]) => form.append(`resource[${field.id}]`, value))

      return form
    },
  },
}
