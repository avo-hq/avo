<template>
  <div>
    <sidebar-link :large="true">
      {{ $t('resources') }}
    </sidebar-link>

    <div class="resources-links w-full">
      <sidebar-link
        v-for="resource in sortedResources"
        :key="resource.resource_name"
        v-text="resourceLabel(resource)"
        :to="{
          name: 'index',
          params: {
            resourceName: resource.resource_name,
          },
        }"
      />
    </div>
  </div>
</template>

<script>
import sortBy from 'lodash/sortBy'
import upperFirst from 'lodash/upperFirst'

export default {
  props: ['resources'],
  computed: {
    sortedResources() {
      return sortBy(this.resources, 'resource_name')
    },
  },
  methods: {
    resourceLabel(resource) {
      return upperFirst(this.$tc(resource.label, 2))
    },
  },
}
</script>
