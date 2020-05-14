import Api from '@/js/Api'
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
    getResourceUrl() {
      if (this.resourceId) return `/avocado/avocado-api/${this.resourceName}/${this.resourceId}/edit`

      return `/avocado/avocado-api/${this.resourceName}/fields`
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
        .forEach(([field, value]) => form.append(`resource[${field.id}]`, value))

      return form
    },
    async getResource() {
      const { data } = await Api.get(this.getResourceUrl)

      this.resource = data.resource
    },
    async submitResource() {
      this.errors = {}

      try {
        await Api({
          method: this.submitMethod,
          url: this.submitResourceUrl,
          data: this.buildFormData(),
        })
      } catch (error) {
        console.log('error->', error)
        const { response } = error
        console.log('response->', response)
        this.errors = response.data.errors
      }
    },
  },
  async mounted() {
    await this.getResource()
  },
}
