<template>
  <div>
    <resources-index
      :resource-name="field.id"
      :via-resource-name="resourceName"
      :via-resource-id="resourceId"
      ></resources-index>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: [
    'resourceName',
    'resourceId',
    'field',
  ],
  computed: {},
  methods: {},
  async mounted() {
    console.log('has-many mounted', this.resourceName)
  },
}
</script>

<style lang="postcss"></style>
