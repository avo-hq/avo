<template>
  <div>
    <sidebar-link :large="true">
      Resources
    </sidebar-link>

    <div class="resources-links w-full">
      <sidebar-link
        v-for="resource in sortedResources"
        :key="resource.resource_name"
        v-text="resource.label"
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

export default {
  props: ['resources'],
  computed: {
    sortedResources() {
      return sortBy(this.resources, 'resource_name')
    },
  },
}
</script>

<style slang="postcss"></style>
