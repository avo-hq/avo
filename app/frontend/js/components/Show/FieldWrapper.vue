<template>
  <div :class="classes" v-if="field">
    <div class="w-1/3 p-4 h-full flex">
      <slot name="label">
        <div class="py-2">
          {{ field.name }} <span class="text-red-600" v-if="field.required">*</span>
        </div>
      </slot>
    </div>
    <div class="w-1/3 py-4">
      <slot />
      <div class="text-red-600 mt-2" v-if="fieldError" v-text="fieldError"></div>
    </div>
  </div>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  data: () => ({}),
  mixins: [FormField],
  props: ['field', 'index', 'errors'],
  computed: {
    classes() {
      const classes = ['flex', 'items-start', 'py-2', 'leading-tight']

      if (this.index !== 0) classes.push('border-t')

      return classes.join(' ')
    },
    fieldError() {
      if (!this.hasErrors) return ''

      return `${this.field.id} ${this.errors[this.field.id].join(', ')}`
    },
    hasErrors() {
      if (isUndefined(this.errors) || isNull(this.errors) || Object.keys(this.errors).length === 0) return false

      return !isUndefined(this.errors[this.field.id])
    },
  },
  methods: {},
  mounted() { },
}
</script>

<style lang="postcss"></style>
