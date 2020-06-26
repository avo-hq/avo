<template>
  <div>
    <resources-index
      data-component="resources-index"
      :data-resource-name="field.id"
      :data-via-resource-name="resourceName"
      :data-via-resource-id="resourceId"
      :resource-name="field.id"
      :via-resource-name="resourceName"
      :via-resource-id="resourceId"
      :field="field"
      ></resources-index>
  </div>
</template>

<script>
export default {
  props: [
    'resourceName',
    'resourceId',
    'field',
  ],
}
</script>
