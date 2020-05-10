<template>
  <div>
    <resource-table
      :resources="resources"
      :resource-name="resourceName"
      ></resource-table>
  </div>
</template>

<script>
import Api from '@/js/Api'

export default {
  data: () => ({
    resources: []
  }),
  props: ['resourceName', 'resourceId', 'field'],
  computed: {
    queryUrl() {
      return `/avocado/avocado-api/${this.field.path}?via_resource_name=${this.resourceName}&via_resource_id=${this.resourceId}`
    }
  },
  methods: {
    async getResources() {
      const { data } = await Api.get(this.queryUrl)
      this.resources = data.resources
    },
  },
  async mounted() {
    console.log('has-many mounted')
    await this.getResources()
  },
}
</script>

<style lang="postcss"></style>
