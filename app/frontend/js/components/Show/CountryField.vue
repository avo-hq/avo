<template>
  <show-field-wrapper :field="field" :index="index">
    {{value}}
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    value() {
      const countryName = this.field.countries[this.field.value]
      if (this.field.display_name && countryName) return countryName

      return this.field.value
    },
  },
}
</script>
