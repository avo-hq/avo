<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="text" v-model="value" />
  </edit-field-wrapper>
</template>

<script>
import { HasInputAppearance, IsFormField } from '@AvocadoHQ/avocado-js'

export default {
  data: () => ({
    value: '',
  }),
  mixins: [HasInputAppearance, IsFormField],
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border-red-600')

      return classes.join(' ')
    },
  },
  methods: {
    /**
     * Set the value of the field when the page is loaded.
    */
    setInitialValue() {
      this.value = this.field.value
    },

    /**
     * Get the value of the field when the form is submitted.
    */
    getValue() {
      return this.value
    },
  },
}
</script>
