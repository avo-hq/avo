<template>
  <show-field-wrapper :field="field" :index="index">
    {{value}}
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    displayValue() {
      return this.field.options[this.field.value]
    },
    value() {
      if (this.field.display_with_value && this.displayValue) return this.displayValue

      return this.field.value
    },
  },
  methods: {},
  mounted() {},
}
</script>
