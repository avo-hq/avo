<template>
  <div>
    <table class="w-full px-4">
      <thead v-if="hasFields" class="bg-gray-200">
        <th class="min-w-8">
          <!-- Select cell -->
        </th>
        <th v-for="field in fields"
          :key="field.id"
          is="table-header-cell"
          :resource-name="resourceName"
          :field="field"
          :sort-by="sortBy"
          :sort-direction="sortDirection"
          @sort="$emit('sort', field.id)"
        ></th>
        <th class="w-24">
          <!-- Controls cell -->
        </th>
      </thead>
      <tbody>
        <tr
          is="table-row"
          v-for="resource in resources"
          :key="resource.id"
          :resource="resource"
          :resource-name="resourceName"
          :via-resource-name="viaResourceName"
          :via-resource-id="viaResourceId"
        ></tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import ExtractsFields from '@/js/mixins/extracts-fields'

export default {
  data: () => ({}),
  mixins: [ExtractsFields],
  props: [
    'resources',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'sortBy',
    'sortDirection',
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
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
