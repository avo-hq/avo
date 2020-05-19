import Api from '@/js/Api'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'
import pluralize from 'pluralize'

export default {
  data: () => ({
    isLoading: false,
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
    submitResourceUrl() {
      if (this.resourceId) return `/avocado/avocado-api/${this.resourceName}/${this.resourceId}`

      return `/avocado/avocado-api/${this.resourceName}`
    },
    submitMethod() {
      if (this.resourceId) return 'put'

      return 'post'
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
        .forEach(([field, value]) => form.append(`resource[${isUndefined(field.db_field) ? field.id : field.db_field}]`, value))

      return form
    },
    async submitResource() {
      this.isLoading = true
      this.errors = {}

      try {
        await Api({
          method: this.submitMethod,
          url: this.submitResourceUrl,
          data: this.buildFormData(),
        })
      } catch (error) {
        const { response } = error
        this.errors = response.data.errors
      }

      this.isLoading = false
    },
  },
}
