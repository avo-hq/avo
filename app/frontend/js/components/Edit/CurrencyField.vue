<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <currency-input
    v-model="value"
    :currency="field.currency"
    :locale="field.locale"
    />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
// eslint-disable-next-line sort-imports-es6-autofix/sort-imports-es6
import { CurrencyInput } from 'vue-currency-input'

export default {
  mixins: [FormField],
  components: { CurrencyInput },
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border', 'border-red-600')

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
