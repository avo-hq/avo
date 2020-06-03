<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div class="flex items-center">
      <template v-if='value'>
      <div class="space-y-3">
          <template v-for="(key, val, index) in value">
            <div v-bind:key="index">
              <input
                type="checkbox"
                :id="field.id"
                :name="field.id"
                :disabled="disabled"
                :checked="key"
                @click="onToggle(val)"
              />
              <label for="field.id">{{ label(val) }}</label>
            </div>
          </template>
        </div>
      </template>
      <template v-else>
        {{field.no_value_text}}
      </template>
    </div>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  data: () => ({
    fieldValues: {},
  }),
  methods: {
    setInitialValue() {
      this.value = this.field.value
      this.fieldValues = this.field.value
    },
    getValue() {
      return this.fieldValues
    },
    label(key) {
      if (this.field.options[key]) return this.field.options[key]
      return key
    },
    onToggle(key) {
      this.fieldValues[key] = !this.fieldValues[key]
    },
  },
}
</script>
