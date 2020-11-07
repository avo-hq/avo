<template>
  <div>
    <sidebar-link :large="true">
      {{ $t('avo.resources') }}
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
            resourceTranslationKey: resource.translation_key,
          },
        }"
      />
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import sortBy from 'lodash/sortBy'
import upperFirst from 'lodash/upperFirst'

export default {
  computed: {
    ...mapState('app', [
      'availableResources',
    ]),
    sortedResources() {
      return sortBy(this.availableResources, 'resource_name')
    },
  },
  methods: {
    resourceLabel(resource) {
      return upperFirst(resource.label)
    },
  },
}
</script>
