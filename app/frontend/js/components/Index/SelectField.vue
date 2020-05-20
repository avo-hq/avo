<template>
  <index-field-wrapper :field="field">
    {{value}}
  </index-field-wrapper>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field'],
  computed: {
    value() {
      if (this.field.options[this.field.value]) return this.field.options[this.field.value]

      return 'No value found!'
    },
  },
  methods: {},
  mounted() {},
}
</script>
