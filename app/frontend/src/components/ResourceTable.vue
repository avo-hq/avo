<template>
  <div>
    <table class="w-full">
      <thead>
        <th v-for="field in fields"
          v-text="field.name"
          v-if="hasFields"
          class="text-left"
          :resource-name="resourceName"
        ></th>
        <th>
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
      if (!this.hasFields) {
        return []
      }

      return this.resources[0].fields
    }
  },
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
