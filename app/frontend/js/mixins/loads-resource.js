import Api from '@/js/Api'
import Avo from '@/js/Avo'
import pluralize from 'pluralize'

export default {
  data: () => ({
    isLoading: false,
  }),
  computed: {
    getResourceUrl() {
      if (this.resourceId) {
        if (this.$route.name === 'show') {
          return `${Avo.rootPath}/avo-api/${this.resourceName}/${this.resourceId}`
        }

        return `${Avo.rootPath}/avo-api/${this.resourceName}/${this.resourceId}/edit`
      }

      return `${Avo.rootPath}/avo-api/${this.resourceName}/fields`
    },
  },
  methods: {
    hydrateRelatedResources(resource) {
      if (this.viaResourceName && this.viaResourceId) {
        resource.fields.forEach((field) => {
          if (field.id === pluralize(this.viaResourceName, 1)) {
            /* eslint-disable camelcase */
            // eslint-disable-next-line no-param-reassign
            field.database_value = parseInt(this.viaResourceId, 10)
            /* eslint-enable camelcase */
          }
        })
      }

      return resource
    },
    async getResource() {
      this.isLoading = true

      const { data } = await Api.get(this.getResourceUrl)

      const resource = this.hydrateRelatedResources(data.resource)

      this.resource = resource

      this.isLoading = false
    },
  },
  async mounted() {
    await this.getResource()
  },
}
