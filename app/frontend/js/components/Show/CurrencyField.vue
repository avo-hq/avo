<template>
  <show-field-wrapper :field="field" :index="index">
    <currency-input
      v-if="field.value"
      v-model="value"
      :currency="field.currency"
      :locale="field.locale"
      class="bg-transparent"
      disabled
    />
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
import { CurrencyInput } from 'vue-currency-input'

export default {
  props: ['field', 'index'],
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
