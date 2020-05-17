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
}
</script>

<style lang="postcss"></style>
