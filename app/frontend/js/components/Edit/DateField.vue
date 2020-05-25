<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="text" ref="datepicker" v-model="value"/>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import flatpickr from 'flatpickr'

require('flatpickr/dist/flatpickr.css')

export default {
  mixins: [FormField],
  methods: {
    setInitialValue() {
      if (this.field.value) this.value = flatpickr.formatDate(new Date(this.field.value), this.field.pickerFormat)

      this.value = this.field.placeholder
    },
    getValue() {
      return flatpickr.parseDate(this.value, this.field.pickerFormat)
    },
  },
  mounted() {
    flatpickr(this.$refs['datepicker'], {
      defaultDate: this.value,
      dateFormat: this.field.pickerFormat,
      locale: {
        firstDayOfWeek: this.field.firstDayOfWeek,
      },
    })
  },
}
</script>
