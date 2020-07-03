<template>
  <index-field-wrapper :field="field">
    <currency-input
      v-if="value"
      v-model="value"
      :currency="field.currency"
      :locale="field.locale"
      class="bg-transparent"
      disabled
    />
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import { CurrencyInput } from 'vue-currency-input'

export default {
  props: ['field'],
  components: { CurrencyInput },
  data: () => ({
    value: 0,
  }),
  methods: {
    setInitialValue() {
      let { value } = this.field

      if (!this.field.value || this.field.value === '') value =  0

      this.value = Number(value, 10)
    },
  },
  mounted() {
    this.setInitialValue()
  },
}
</script>
