<template>
  <show-field-wrapper :field="field" :index="index">
    <template v-if="value">
      <div v-text="value"></div>
    </template>

    <empty-dash v-else />

    <template #extra>
      <span v-if="displayTimezone" class="px-4 items-center flex text-gray-500">({{ timezone }})</span>
    </template>
  </show-field-wrapper>
</template>

<script>
import { IsFormField } from '@avo-hq/avo-js'
import moment from 'moment'

export default {
  mixins: [IsFormField],
  data: () => ({
    displayTimezone: false,
  }),
  methods: {
    setInitialValue() {
      if (this.field.value) {
        if (this.field.from_now) {
          this.value = moment(new Date(this.field.value)).fromNow()
        } else {
          this.value = moment(this.field.value).format(this.field.format)
        }
      } else {
        this.value = null
      }

      if (this.field.enable_time && this.field.value) {
        this.displayTimezone = true
        this.timezone = Intl.DateTimeFormat().resolvedOptions().timeZone
      }
    },
  },
}
</script>
