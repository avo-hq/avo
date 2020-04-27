<template>
  <div>
    <table class="w-full px-4">
      <thead v-if="hasFields" class="bg-gray-200">
        <th class="w-8">
          <!-- Select cell -->
        </th>
        <th v-for="field in fields"
          :key="field.id"
          v-text="field.name"
          class="text-left uppercase text-sm py-2"
          :resource-name="resourceName"
        ></th>
        <th class="w-24">
          <!-- Control cell -->
        </th>
      </thead>
      <tbody>
        <tr
          is="table-row"
          v-for="resource in resources"
          :key="resource.id"
          :resource="resource"
          :resource-name="resourceName"
        ></tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: [
    'resources',
    'resourceName',
  ],
  computed: {
    hasFields() {
      return this.resources && this.resources.length > 0 && this.resources[0].fields && this.resources[0].fields.length > 0
    },
    fields() {
      if (!this.hasFields) return []

      return this.resources[0].fields
    },
  },
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
