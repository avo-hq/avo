import Api from '@/js/Api'
import Avo from '@/js/Avo'
import Bus from '@/js/Bus'
import Resource from '@/js/models/Resource'
import hasLoadingBus from '@/js/mixins/has-loading-bus'
import pluralize from 'pluralize'
import replace from 'lodash/replace'

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
    resourceNameFromURL() {
      if (!this.resource) return replace(pluralize(this.resourceName, 1), '_', ' ')

      return this.resource.singular_name
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
      this.resource = new Resource(resource)
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
