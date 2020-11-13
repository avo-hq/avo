<template>
  <show-field-wrapper :field="field" :index="index">
    <div class="space-y-2" v-if="value">
      <template v-for="(val, key, index) in parsedValue">
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
  computed: {
    parsedValue() {
      if (this.field.value) {
        const result = {}

        Object.keys(this.field.value).forEach((key) => {
          const value = this.field.value[key]
          if (value === true || value === false) {
            result[key] = value
          }
        })

        return result
      }

      return {}
    },
  },
  methods: {
    label(key) {
      if (this.field.options[key]) return this.field.options[key]

      return key
    },
  },
}
</script>
