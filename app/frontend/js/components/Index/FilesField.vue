<template>
  <index-field-wrapper :field="field">
    {{filedLabel}}
  </index-field-wrapper>
</template>

<script>
import pluralize from 'pluralize'

export default {
  props: ['field'],
  computed: {
    filedLabel() {
      if (this.field.value && this.field.value.length > 0) {
        return `${this.field.value.length} ${pluralize(this.field.name, this.field.value.length)}`
      }

      return '-'
    },
  },
}
</script>
