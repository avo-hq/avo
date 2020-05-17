import Api from '@/js/Api'

export default {
  data: () => ({
    isLoading: false,
  }),
  computed: {
    getResourceUrl() {
      if (this.resourceId) return `/avocado/avocado-api/${this.resourceName}/${this.resourceId}/edit`

      return `/avocado/avocado-api/${this.resourceName}/fields`
    },
  },
  methods: {
    async getResource() {
      this.isLoading = true

      const { data } = await Api.get(this.getResourceUrl)

      this.resource = data.resource

      this.isLoading = false
    },
  },
  async mounted() {
    await this.getResource()
  },
}
