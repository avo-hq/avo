<template>
  <index-field-wrapper :field="field">
    {{value}}
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
  computed: {
    value() {
      const countryName = this.field.countries[this.field.value]
      if (this.field.display_name && countryName) return countryName

      return this.field.value
    },
  },
}
</script>
