<template>
  <show-field-wrapper :field="field" :index="index">
    <div class="space-y-3" v-if="value">
      <template v-for="(val, key, index) in value">
        <div v-bind:key="index">
          <component :is="component(val)" :class="classes(val)" />
          <div class="text-lg ml-8">{{ label(key) }}</div>
        </div>
      </template>
    </div>
    <empty-dash v-else />
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
    label(key) {
      if (this.field.options[key]) return this.field.options[key]

      return key
    },
    classes(value) {
      let classes = 'h-6 float-left'

      if (value) {
        classes += ' text-green-600'
      } else {
        classes += ' text-red-600'
      }

      return classes
    },
    component(value) {
      if (value) return 'check-circle-icon'

      return 'x-circle-icon'
    },
  },
}
</script>
