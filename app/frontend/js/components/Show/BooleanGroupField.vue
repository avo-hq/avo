<template>
  <show-field-wrapper :field="field" :index="index">
    <div class="space-y-2" v-if="value">
      <template v-for="(val, key, index) in value">
        <div v-bind:key="index">
          <boolean-check :checked="val"/>
          <div class="ml-6 text-left py-px">{{ label(key) }}</div>
        </div>
      </template>
    </div>
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import BooleanCheck from '@/js/components/BooleanCheck.vue'

export default {
  mixins: [IsFormField],
  props: ['field', 'index'],
  components: { BooleanCheck },
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
  },
}
</script>
