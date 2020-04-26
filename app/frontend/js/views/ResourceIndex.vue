<template>
  <div>
    <view-header>
      <template #heading>
        {{resourceName}}
      </template>

      <template #search>
        <input type="text" placeholder="search"/>
      </template>
      <template #tools>

        <router-link
          :to="{
            name: 'new',
            params: {
              resourceName: resourceName,
            },
          }"
          class="button"
        >Create new {{resourceNameSingular}}</router-link>
      </template>
    </view-header>

    <div class="flex justify-between items-center mb-4">
    </div>


    <panel>
      <resource-table
        :resources="resources"
        :resource-name="resourceName"
        ></resource-table>
    </panel>
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
  computed: {
    resourceNameSingular() {
      if (this.resources && this.resources.length > 0) {
        return this.resources[0].resource_name_singular
      }
    },
  },
  methods: {},
  async mounted() {
    console.log('mounted')
    const {data} = await axios.get(`/avocado/avocado-api/${this.resourceName}`)

    this.resources = data.resources
  },
}
</script>
