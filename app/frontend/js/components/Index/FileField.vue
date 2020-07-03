<template>
  <index-field-wrapper :field="field">
    <a :href="field.value"
      v-text="field.filename"
      v-tooltip="`Download ${field.filename}`"
      v-if="this.field.value"
      download
    ></a>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
}
</script>
