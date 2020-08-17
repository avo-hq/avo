import Api from '@/js/Api'
import Avo from '@/js/Avo'
import hasLoadingBus from '@/js/mixins/has-loading-bus'

export default {
  mixins: [hasLoadingBus],
  data: () => ({
    actions: [],
  }),
  methods: {
    async getActions() {
      let response

      if (this.resourceId) {
        response = await Api.get(`${Avo.rootPath}/avo-api/${this.resourceName}/actions?resource_id=${this.resourceId}`)
      } else {
        response = await Api.get(`${Avo.rootPath}/avo-api/${this.resourcePath}/actions`)
      }

      const { data } = response

      this.actions = data.actions
    },
  },
  created() {
    this.addToBus(this.getActions)
  },
}
