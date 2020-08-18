<template>
  <index-field-wrapper :field="field">
    <div v-if="value" v-text="value"></div>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field'],
  computed: {
    label() {
      return this.field.options[this.field.value]
    },
    value() {
      if (!this.field.display_value && this.label) return this.label

      return this.field.value
    },
  },
  methods: {},
  mounted() {},
}
</script>
