import { objectToFormData } from 'object-to-formdata'
import Api from '@/js/Api'
import isNull from 'lodash/isNull'
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
      const formData = {
        resource: {},
      }

      // eslint-disable-next-line no-return-assign
      this.fields.forEach((field) => {
        const id = field.getId()
        if (id) {
          formData.resource[id] = isNull(field.getValue()) ? '' : field.getValue()
        }
      })

      return objectToFormData(formData)
    },
    async submitResource() {
      // return this.buildFormData()
      this.isLoading = true
      this.errors = {}

      try {
        await Api({
          method: this.submitMethod,
          url: this.submitResourceUrl,
          data: this.buildFormData(),
          headers: {
            'Content-Type': 'multipart/form-data',
            // 'Content-Type': 'application/x-www-form-urlencoded',
          },
        })
      } catch (error) {
        const { response } = error
        this.errors = response.data.errors
      }

      this.isLoading = false
    },
  },
}
