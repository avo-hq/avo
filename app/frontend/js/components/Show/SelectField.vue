<template>
  <show-field-wrapper :field="field" :index="index">
    {{value}}
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    label() {
      return this.field.options[this.field.value]
    },
    value() {
      if (this.field.display_with_value && this.label) return this.label

      return this.field.value
    },
  },
  methods: {},
  mounted() {},
}
</script>
