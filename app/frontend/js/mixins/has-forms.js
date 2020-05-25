import { objectToFormData } from 'object-to-formdata'
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
      const formData = {
        resource: {},
        // eslint-disable-next-line camelcase
        file_fields: {},
      }

      const updatableFields = this.resource
        .fields
        .filter((field) => field.updatable)
        .filter((field) => !field.computed)

      updatableFields
        .filter((field) => !field.is_file_field)
        // eslint-disable-next-line no-return-assign
        .forEach((field) => formData.resource[field.id] = isNull(field.getValue()) ? '' : field.getValue())

      updatableFields
        .filter((field) => field.is_file_field)
        // eslint-disable-next-line no-return-assign
        .forEach((field) => formData.file_fields[field.id] = field.getFileFieldValue())

      console.log('formData->', (formData))
      console.log('objectToFormData(formData)->', objectToFormData(formData))

      return objectToFormData(formData)
    },
    async submitResource() {
      // this.buildFormData()
      // return
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
