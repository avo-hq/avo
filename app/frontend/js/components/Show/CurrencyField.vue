<template>
  <show-field-wrapper :field="field" :index="index">
    <currency-input
    v-if="field.value"
    v-model="field.value"
    :currency="field.currency"
    :locale="field.locale"
    disabled
    />
    <div v-else>
      -
    </div>
  </show-field-wrapper>
</template>

<script>
// eslint-disable-next-line sort-imports-es6-autofix/sort-imports-es6
import { CurrencyInput } from 'vue-currency-input'

export default {
  props: ['field', 'index'],
  components: { CurrencyInput },
}
</script>

<style>
input:disabled {
  background: #ffffff;
}
</style>
