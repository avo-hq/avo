<template>
  <show-field-wrapper :field="field" :index="index">
    <div v-text="value"></div>
    <template #extra>
      <span v-if="displayTimezone" class='px-4 items-center flex text-gray-500'> ({{timezone}})</span>
    </template>
  </show-field-wrapper>
</template>
<script>
import FormField from '@/js/mixins/form-field'
import moment from 'moment'

export default {
  mixins: [FormField],
  data: () => ({
    displayTimezone: false,
  }),
  methods: {
    setInitialValue() {
      if (this.field.value) this.value = moment(new Date(this.field.value)).format(this.field.format)
      else this.value = '-'

      if (this.field.enable_time && this.field.value) {
        this.displayTimezone = true
        this.timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
      }
    },
  },
}
</script>
