<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index" :displayed-in="displayedIn">
    <currency-input
      ref="field-input"
      :id="field.id"
      :class="classes"
      :disabled="disabled"
      :placeholder="field.placeholder"
      v-model="value"
      :currency="field.currency"
      :locale="field.locale"
    />
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [FormField, HasInputAppearance],
  computed: {
    classes() {
      const classes = ['w-full', this.inputClasses]

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
  },
  methods: {
    setInitialValue() {
      if (this.field.value) {
        this.value = Number(this.field.value, 10)
      } else {
        this.value = null
      }
    },
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$el.focus()
    },
  },
  created() {
    this.setInitialValue()
  },
}
</script>
