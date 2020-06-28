<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
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
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border-red-600')

      return classes.join(' ')
    },
  },
}
</script>
