<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="number"
      :min="min"
      :max="max"
      :step="step"
      :class="classes"
      :disabled="disabled"
      v-model="value"
    >
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({}),
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
    min() {
      return this.field.min
    },
    max() {
      return this.field.max
    },
    step() {
      return this.field.step
    },
  },
  methods: {},
}
</script>

<style lang="postcss"></style>
