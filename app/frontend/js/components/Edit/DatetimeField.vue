<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <input type="text" ref="datetimepicker" v-model="value" :placeholder="field.placeholder" class='w-full'/>
    <template #extra>
      <span v-if="displayTimezone" class='px-4 items-center flex text-gray-500'> ({{timezone}})</span>
    </template>
  </edit-field-wrapper>
</template>

<script>
import 'flatpickr/dist/flatpickr.css'
import FormField from '@/js/mixins/form-field'
import flatpickr from 'flatpickr'

export default {
  mixins: [FormField],
  data: () => ({
    enableTime: false,
    displayTimezone: false,
    value: '',
  }),
  methods: {
    setInitialValue() {
      // sets the value of the field and formats it to flatpiuckr format
      if (this.field.value) this.value = flatpickr.formatDate(new Date(this.field.value), this.field.picker_format)

      // enable time settings
      if (this.field.enable_time) this.enableTime = true

      // enable timezone displayed
      if (this.field.enable_time && this.field.value) {
        this.displayTimezone = true
        this.timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
      }
    },
    getValue() {
      return flatpickr.parseDate(this.value, this.field.picker_format)
    },
  },
  mounted() {
    flatpickr(this.$refs.datetimepicker, {
      // defaultDate: this.value,
      dateFormat: this.field.picker_format,
      enableTime: this.enableTime,
      enableSeconds: this.enableTime,
      locale: {
        firstDayOfWeek: this.field.first_day_of_week,
      },
    })
  },
}
</script>
