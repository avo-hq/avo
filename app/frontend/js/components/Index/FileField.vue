<template>
  <index-field-wrapper :field="field">
    <a :href="field.value"
      v-tooltip="`Download ${field.filename}`"
      v-if="this.field.value"
      download
    >
      <img v-if="field.is_image"
        :src="field.value"
        />
      <span v-text="field.filename" v-else />
    </a>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
}
</script>
