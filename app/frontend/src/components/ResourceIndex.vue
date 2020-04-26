<template>
  <div>
    <div class="text-2xl font-bold pb-4">ResourceIndex</div>

    <div class="bg-white">
      <resource-table
        :resources="resources"
        :resource-name="resourceName"
        ></resource-table>
    </div>
  </div>
</template>

<script>
// import Vue from 'vue'

export default {
  name: 'ResourceIndex',
  data: () => ({
    resources: [],
  }),
  props: [
    'resourceName',
  ],
  computed: {},
  methods: {},
  async mounted() {
    console.log('mounted')
    const {data} = await axios.get(`/avocado/avocado-api/${this.resourceName}`)

    this.resources = data.resources
  },
}
</script>
