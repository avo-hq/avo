<template>
  <index-field-wrapper :field="field">
    <div v-if="value" v-text="value"/>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
  computed: {
    value() {
      if (this.field.value && this.field.value.length > 0) {
        if (this.field.tname) {
          return this.$tc('number_of_items', this.field.value.length, { item: this.$tc(this.field.tname, this.field.value.length) })
        }

        return this.$tc('number_of_items', this.field.value.length, { item: this.field.name })
      }

      return null
    },
  },
}
</script>
