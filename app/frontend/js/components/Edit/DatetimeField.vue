<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="text" ref="datetimepicker" v-model="value" :placeholder="field.placeholder"/>
  </edit-field-wrapper>
</template>

<script>
import FormField from '@/js/mixins/form-field'
import flatpickr from 'flatpickr'
import 'flatpickr/dist/flatpickr.css'

export default {
  mixins: [FormField],
  methods: {
    setInitialValue() {
      if (this.field.value) this.value = flatpickr.formatDate(new Date(this.field.value), this.field.pickerFormat)
    },
    getValue() {
      return flatpickr.parseDate(this.value, this.field.pickerFormat)
    },
  },
  mounted() {
    flatpickr(this.$refs.datetimepicker, {
      defaultDate: this.value,
      dateFormat: this.field.picker_format,
      locale: {
        firstDayOfWeek: this.field.first_day_of_week,
      },
    })
  },
}
</script>
