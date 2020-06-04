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
  props: [
    'resourceName',
    'resourceId',
    'field',
  ],
}
</script>
