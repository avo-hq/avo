import pluralize from 'pluralize'

export default {
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
        // .forEach((field) => console.log(field))
        .forEach((field) => form.append(`resource[${field.id}]`, String(field.getValue())))

      return form
    },
  },
}
