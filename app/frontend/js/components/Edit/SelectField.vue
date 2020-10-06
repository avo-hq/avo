<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <select class="select-input w-full"
      ref="field-input"
      :class="inputClasses"
      v-model="value"
    >
      <option v-if="!value" :value="value" v-text="field.placeholder" disabled/>
      <option v-for="(label, value) in options"
        :value="value"
        :key="value"
        v-text="optionLabel(label, value)"
      />
    </select>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'
import invert from 'lodash/invert'

export default {
  mixins: [FormField, HasInputAppearance],
  computed: {
    options() {
      if (this.field.enum) {
        if (this.field.display_value) {
          return this.field.enum
        }

        return invert(this.field.enum)
      }

      return this.field.options
    },
  },
  methods: {
    setInitialValue() {
      if (this.field.enum) {
        if (this.field.display_value) {
          this.value = this.field.value
        } else {
          this.value = this.field.enum[this.field.value]
        }
      } else {
        this.value = this.field.value
      }
    },
    optionLabel(label, value) {
      if (this.field.display_value || this.field.enum) return value

      return label
    },
  },
}
</script>
