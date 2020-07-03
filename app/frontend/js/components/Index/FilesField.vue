<template>
  <index-field-wrapper :field="field">
    <div v-if="value" v-text="value"/>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import pluralize from 'pluralize'

export default {
  props: ['field'],
  computed: {
    value() {
      if (this.field.value && this.field.value.length > 0) {
        return `${this.field.value.length} ${pluralize(this.field.name, this.field.value.length)}`
      }

      return null
    },
  },
}
</script>
