import { objectToFormData } from 'object-to-formdata'
import Api from '@/js/Api'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  data: () => ({
    isLoading: false,
    errors: {},
  }),
  computed: {
    afterSuccessPath() {
      if (!isUndefined(this.viaResourceName)) return `/resources/${this.viaResourceName}/${this.viaResourceId}`

      return `/resources/${this.resourceName}/${this.resource.id}`
    },
    fields() {
      if (!this.resource || !this.resource.fields || this.resource.fields.length === 0) {
        return []
      }

      return this.resource
        .fields
        .filter((field) => ['has_and_belongs_to_many', 'has_many'].indexOf(field.relationship) === -1)
        .filter((field) => !field.computed)
    },
    submitResourceUrl() {
      if (this.resourceId) return `/avo/avo-api/${this.resourceName}/${this.resourceId}`

      return `/avo/avo-api/${this.resourceName}`
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

      if (this.viaResourceName) {
        // eslint-disable-next-line camelcase
        formData.via_resource_name = this.viaResourceName
      }
      if (this.viaRelationship) {
        // eslint-disable-next-line camelcase
        formData.via_relationship = this.viaRelationship
      }
      if (this.viaResourceId) {
        // eslint-disable-next-line camelcase
        formData.via_resource_id = this.viaResourceId
      }

      this.fields.filter((filter) => filter.updatable).forEach((field) => {
        const id = field.getId()
        const value = isNull(field.getValue()) ? '' : field.getValue()

        if (id) {
          formData.resource[id] = value
        }
      })

      return objectToFormData(formData)
    },
    async submitResource() {
      this.isLoading = true
      this.errors = {}

      try {
        const { data } = await Api({
          method: this.submitMethod,
          url: this.submitResourceUrl,
          data: this.buildFormData(),
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })

        const { success } = data
        const { resource } = data

        this.resource = resource

        if (success) {
          this.$router.push(this.afterSuccessPath)
        }
      } catch (error) {
        const { response } = error

        if (response) {
          this.errors = response.data.errors
        } else {
          throw error
        }
      }

      this.isLoading = false
    },
  },
}
