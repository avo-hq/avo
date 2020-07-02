<template>
  <textarea
    ref="field-input"
    v-if="type === 'textarea'"
    :id="id"
    :class="inputClasses"
    :disabled="disabled"
    :value="value"
    @input="$emit('input', $event.target.value)"
    cols="30"
    rows="10"
    ></textarea>

  <currency-input
    ref="field-input"
    v-else-if="type === 'currency'"
    :value="value"
    :currency="currency"
    :locale="locale"
    :id="id"
    :class="inputClasses"
    :disabled="disabled"
    @input="emitChanges"
  />
  <input
    ref="field-input"
    v-else
    :type="type"
    :class="inputClasses"
    :id="id"
    :disabled="disabled"
    :value="value"
    :min="min"
    :max="max"
    :step="step"
    @input="$emit('input', $event.target.value)"
  />
</template>

<script>
// import { CurrencyDirective } from 'vue-currency-input'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [HasInputAppearance],
  directives: {
    // currency: CurrencyDirective,
  },
  props: {
    id: {},
    disabled: {},
    value: {},
    min: {},
    max: {},
    step: {},
    type: {
      type: String,
      default: 'text',
    },
    currency: {},
    locale: {},
  },
  methods: {
    emitChanges(value) {
      // console.log('$event->', $event)
      const parsedValue = this.$parseCurrency(value, {
        currency: this.currency,
        locale: this.locale,
      })

      console.log('parsedValue->', parsedValue)
      this.$emit('input', parsedValue)
    },
  },
  mounted() {
    this.$on('focus', () => this.$refs['field-input'].focus())
  },
  destroyed() {
    this.$off('focus')
  },
}
</script>
