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
        if (this.field.translation_key) {
          return this.$t('avo.number_of_items', { item: this.$t(this.field.translation_key, { count: this.field.value.length }), count: this.field.value.length })
        }

        return this.$t('avo.number_of_items', { item: this.field.name, count: this.field.value.length })
      }

      return null
    },
  },
}
</script>
