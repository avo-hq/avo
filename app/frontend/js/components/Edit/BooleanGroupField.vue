<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <div class="flex items-center">
      <div class="space-y-3">
        <template v-for="(value, name, index) in fieldValues">
          <div :key="index" @click="toggleOption(name)">
            <input
              type="checkbox"
              :name="name"
              :checked="value"
              :disabled="disabled"
              class="w-3 h-3"
            />
            <label class="ml-1">{{ labelForOption(name) }}</label>
          </div>
        </template>
      </div>
    </div>
  </edit-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  mixins: [IsFormField],
  data: () => ({
    fieldValues: {},
  }),
  computed: {
    parsedValue() {
      if (isNull(this.field.value) || isUndefined(this.field.value)) return {}

      return this.field.value
    },
  },
  methods: {
    setInitialValue() {
      this.value = this.field.value

      Object.keys(this.field.options).forEach((key) => {
        this.$set(this.fieldValues, key, this.parsedValue[key] ? this.parsedValue[key] : false)
      })
    },
    getValue() {
      return this.fieldValues
    },
    labelForOption(name) {
      return this.field.options[name]
    },
    toggleOption(name) {
      this.fieldValues[name] = !this.fieldValues[name]
    },
  },
}
</script>
