<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="text" v-model="value" />
  </edit-field-wrapper>
</template>

<script>
import { HasInputAppearance, IsFormField } from '@AvocadoHQ/avocado-js'
// import { HasInputAppearance } from '@AvocadoHQ/avocado-js'

export default {
  data: () => ({
    value: '',
  }),
  mixins: [IsFormField],
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border-red-600')

      return classes.join(' ')
    },
  },
  methods: {
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
}
</script>
