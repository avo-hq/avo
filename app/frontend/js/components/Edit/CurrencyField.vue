<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input-component
      type="currency"
      v-model="value"
      :currency="field.currency"
      :locale="field.locale"
    />
    {{value}}
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'

export default {
  mixins: [FormField],
  computed: {
    classes() {
      const classes = ['w-full']

      if (this.hasErrors) classes.push('border', 'border-red-600')

      return classes.join(' ')
    },
  },
  methods: {
    setInitialValue() {
      if (!this.field.value || this.field.value === '') this.value =  0

      this.value = Number(this.field.value)
      // console.log('this.value->', this.value)
    },
    focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].$emit('focus')
    },
  },
  created() {
    this.setInitialValue()
  },
}
</script>
