<template>
  <show-field-wrapper :field="field" :index="index">
    <template v-for="(val, key, index) in value">
      <div v-bind:key="index">
        <boolean-check :checked="val"/>
        <div class="ml-6 text-left py-px">{{ label(key) }}</div>
      </div>
    </template>
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
      const result = {}
      Object.keys(this.field.options).forEach((key) => {
        result[key] = (this.field.value && key in this.field.value && this.field.value[key] === true)
      })
      this.value = result
    },
    label(key) {
      if (this.field.options[key]) return this.field.options[key]

      return key
    },
  },
}
</script>
