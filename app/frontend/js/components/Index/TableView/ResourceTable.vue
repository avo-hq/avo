<template>
  <div class="w-full">
    <table class="w-full px-4 overflow-hidden" :class="{'rounded-b-xl': totalPages === 1}">
      <thead v-if="hasFields" class="bg-gray-200 border-t border-b border-gray-500 pb-1">
        <th>
          <!-- Select cell -->
        </th>
        <th v-for="(field, index) in fields"
          :key="index"
          is="table-header-cell"
          :resource-name="resourceName"
          :field="field"
          :sort-by="sortBy"
          :sort-direction="sortDirection"
          @sort="$emit('sort', field.id)"
        />
        <th class="w-24">
          <!-- Controls cell -->
        </th>
      </thead>
      <tbody>
        <tr
          is="table-row"
          v-for="(resource, index) in resources"
          :class="{'border-b': resources.length - 1 === index ? totalPages > 1 : true}"
          :key="index"
          :resource="resource"
          :resource-name="resourceName"
          :via-resource-name="viaResourceName"
          :via-resource-id="viaResourceId"
          :field="field"
          @resource-deleted="$emit('resource-deleted')"
        />
      </tbody>
    </table>
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
    'totalPages',
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
