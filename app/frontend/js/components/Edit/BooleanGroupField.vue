<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div class="flex items-center">
      <div class="space-y-3">
        <template v-for="(value, name, index) in fieldValues">
          <div :key="index" @click="toggleOption(name)">
            <input
              type="checkbox"
              :id="field.id"
              :name="name"
              :checked="value"
              :disabled="disabled"
            />
            <label>{{ labelForOption(name) }}</label>
          </div>
        </template>
      </div>
    </div>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  mixins: [FormField],
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
