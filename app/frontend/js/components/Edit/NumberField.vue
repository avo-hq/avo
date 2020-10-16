<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <input-component
      ref="field-input"
      type="number"
      :id="field.id"
      :min="min"
      :max="max"
      :step="step"
      :class="classes"
      :disabled="disabled"
      :placeholder="field.placeholder"
      v-model="value"
    />
  </edit-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'

export default {
  mixins: [IsFormField],
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
  methods: {
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
}
</script>
