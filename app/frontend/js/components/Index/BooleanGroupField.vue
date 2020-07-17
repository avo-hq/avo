<template>
  <index-field-wrapper :field="field" class="text-center">
    <template v-if="isVisible">
      <div class="space-y-3" v-if="value">
        <template v-for="(val, key, index) in value">
          <div v-bind:key="index">{{ emoji(val) }} {{ label(key) }}</div>
        </template>
      </div>
      <empty-dash v-else />
    </template>
    <a href="javascript:void(0);"
      @click="toggleView"
      v-else
    >
      View
    </a>
  </index-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  props: ['field'],
  data: () => ({
    isVisible: false,
  }),
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
    toggleView() {
      this.isVisible = true
    },
  },
}
</script>
