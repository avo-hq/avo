<template>
  <div class="w-full grid grid-cols-3 gap-6">
    <div
      is="grid-item"
      v-for="(resource, index) in resources"
      :key="index"
      :resource="resource"
      :resource-name="resourceName"
      :via-resource-name="viaResourceName"
      :via-resource-id="viaResourceId"
      :field="field"
      @resource-deleted="$emit('resource-deleted')"
    />
  </div>
</template>

<script>
import ExtractsFields from '@/js/mixins/extracts-fields'

export default {
  mixins: [ExtractsFields],
  props: [
    'resources',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'sortBy',
    'sortDirection',
    'field',
  ],
  computed: {
    resourceFields() {
      if (this.resources
        && this.resources.length > 0
        && this.resources[0].fields
        && this.resources[0].fields.length > 0) return this.resources[0].fields

      return []
    },
  },
}
</script>
