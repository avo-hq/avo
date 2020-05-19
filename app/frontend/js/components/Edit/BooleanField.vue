<template>
<edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="checkbox"
      :id="field.id"
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
  },
  methods: {
    getValue() {
      switch (this.value) {
        case true:
          return this.field.true_value
        default:
        case false:
          return this.field.false_value
      }
    },
  },
}
</script>

<style lang="postcss"></style>
