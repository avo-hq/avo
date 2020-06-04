<template>
  <show-field-wrapper :field="field" :index="index">
    <template v-if="value">
      <div class="space-y-3">
        <template v-for="(val, key, index) in value">
          <div v-bind:key="index">{{ emoji(val) }} {{ label(key) }}</div>
        </template>
      </div>
    </template>
    <template v-else>
      {{field.no_value_text}}
    </template>
  </show-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field';

export default {
  mixins: [FormField],
  props: ['field', 'index'],
  methods: {
    setInitialValue() {
      if (this.field.value) {
        const values = this.field.value
        const result = {}
        for (let [key, value] of Object.entries(values)) {
          if (
            (value === true && !this.field.hide_true_values) ||
            (value === false && !this.field.hide_false_values)
          ) {
            result[key] = value
          }
        }
        this.value = result
      }
    },
    emoji(booly) {
      if (booly === true) return '✅'
      return '❌'
    },
    label(key) {
      if (this.field.options[key]) return this.field.options[key]
      return key
    },
  },
}
</script>
