<template>
  <index-field-wrapper :field="field">
    <div v-if="value" v-text="value"/>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import moment from 'moment'

export default {
  props: ['field'],
  computed: {
    value() {
      if (this.field.value) {
        if (this.field.relative) return moment(new Date(this.field.value)).fromNow()

        return moment(new Date(this.field.value)).format(this.field.format)
      }

      return null
    },
  },
}
</script>
