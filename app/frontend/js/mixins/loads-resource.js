import Api from '@/js/Api'
import Avo from '@/js/Avo'
import Bus from '@/js/Bus'
import hasLoadingBus from '@/js/mixins/has-loading-bus'
import pluralize from 'pluralize'

export default {
  mixins: [hasLoadingBus],
  data: () => ({
    isLoading: false,
  }),
  computed: {
    resourceUrl() {
      if (this.resourceId) {
        if (this.$route.name === 'show') {
          return `${Avo.rootPath}/avo-api/${this.resourceName}/${this.resourceId}`
        }

        return `${Avo.rootPath}/avo-api/${this.resourceName}/${this.resourceId}/edit`
      }

      return `${Avo.rootPath}/avo-api/${this.resourceName}/new`
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

      const { data } = await Api.get(this.resourceUrl)

      if (!data) return
      let { resource } = data

      if (!resource) return

      resource = this.hydrateRelatedResources(resource)
      this.resource = resource
      this.isLoading = false
    },
  },
  created() {
    this.addToBus(this.getResource)
  },
  mounted() {
    Bus.$on('reload-resources', this.getResource)
  },
  destroyed() {
    Bus.$off('reload-resources')
  },
}
