<template>
  <tr v-if="resource">
    <component
      v-for="field in resource.fields"
      :key="field.id"
      :is="`index-${field.component}`"
      :value="field.value"
    ></component>

    <td class="text-right">
      <router-link
        :to="{
          name: 'detail',
          params: {
            resourceName: resourceName,
            resourceId: resource.id,
          },
        }">view</router-link>
      edit
      delete
    </td>
  </tr>
</template>

<script>
export default {
  // name: 'TableRow',
  data: () => ({}),
  props: [
    'resource',
    'resourceName',
  ],
  methods: {},
  mounted() {
    console.log(this.resourceName, this.resourceId)
  },
}
</script>

<style lang="postcss"></style>

