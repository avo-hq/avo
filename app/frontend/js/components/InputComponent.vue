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
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [HasInputAppearance],
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
  },
  mounted() {
    this.$on('focus', () => this.$refs['field-input'].focus())
  },
  destroyed() {
    this.$off('focus')
  },
}
</script>
