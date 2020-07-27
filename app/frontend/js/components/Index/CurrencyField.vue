<template>
  <index-field-wrapper :field="field">
    <currency-input
      v-if="field.value"
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
      if (this.field.value) {
        this.value = Number(this.field.value, 10)
      } else {
        this.value = null
      }
    },
  },
  mounted() {
    this.setInitialValue()
  },
}
</script>
