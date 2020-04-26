<template>
  <div>
    ResourceDetail

    <div class="bg-white">
      {{resource}}
    </div>
  </div>
</template>

<script>
// import Vue from 'vue'

export default {
  name: 'ResourceDetail',
  data: () => ({
    resource: null,
  }),
  props: [
    'resourceName',
    'resourceId',
  ],
  computed: {},
  methods: {
    async getResource() {
      const {data} = await axios.get(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}`)

      this.resource = data.resource

    },
  },
  async mounted() {
    await this.getResource()
  },
}
</script>
