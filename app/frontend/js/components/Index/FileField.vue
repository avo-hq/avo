<template>
  <index-field-wrapper :field="field">
    <a :href="field.value"
      v-tooltip="`Download ${field.filename}`"
      v-if="this.field.value"
      class="block h-8"
      download
    >
      <img v-if="field.is_image"
        :src="field.value"
        class="max-h-full"
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
