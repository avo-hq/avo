<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <input-component
      ref="field-input"
      :id="field.id"
      :class="classes"
      :disabled="disabled"
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

      if (this.hasErrors) classes.push('border-red-600')

      return classes.join(' ')
    },
  },
}
</script>
