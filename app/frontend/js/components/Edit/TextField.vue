<template>
  <field-wrapper :field="field" :errors="errors">
    <input type="text"
      :class="classes"
      v-model="value"
    >
    <br>
    <div class="text-red-600" v-if="fieldError" v-text="fieldError"></div>
  </field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import isUndefined from 'lodash/isUndefined'

export default {
  mixins: [FormField],
  data: () => ({}),
  props: {
    field: {},
    errors: {
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    classes() {
      const classes = []

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
    fieldError() {
      if (!this.hasErrors) return ''

      return `${this.field.id} ${this.errors[this.field.id].join(', ')}`
    },
    hasErrors() {
      if (Object.keys(this.errors).length === 0) return false

      return !isUndefined(this.errors[this.field.id])
    },
  },
  methods: {},
}
</script>

<style lang="postcss"></style>
