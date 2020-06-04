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
    -
    </template>
  </show-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  props: ['field', 'index'],
  methods: {
    setInitialValue() {
      if (this.field.value) {
        const values = this.field.value
        const result = {}
        Object.keys(values).forEach((key) => {
          const value = values[key]
          if (value === true || value === false) {
            result[key] = value
          }
        })
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
