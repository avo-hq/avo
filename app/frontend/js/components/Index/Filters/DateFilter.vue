<template>
  <filter-wrapper :name="filter.name" :index="index">
    <!-- <select :name="filter.id"
      :id="filter.id"
      @change="changeFilter"
      v-model="value"
      :class="inputClasses"
      class="select-input w-full mb-0"
    >
      <option value="">—</option>
      <option v-for="(value, name) in filter.options"
        :value="name"
        v-text="value"
        :key="name"/>
    </select> -->
    <flat-pickr
      ref="field-input"
      class="w-full"
      v-model="value"
      :enable-time="flatpickrConfig.enableTime"
      :config="flatpickrConfig"
      :placeholder="field.placeholder"
    />
  </filter-wrapper>
</template>

<script>
import '~/flatpickr/dist/flatpickr.css'
import { HasInputAppearance } from '@avo-hq/avo-js'
import flatPickr from 'vue-flatpickr-component'

export default {
  mixins: [HasInputAppearance],
  components: { flatPickr },
  data: () => ({
    value: '',
    timezone: '',
    appTimezone: 'UTC',
    enableTime: false,
    displayTimezone: false,
    flatpickrConfig: {
      dateFormat: 'Y-m-d',
      enableTime: false,
      enableSeconds: false,
      // eslint-disable-next-line camelcase
      time_24hr: false,
      locale: {
        firstDayOfWeek: 0,
      },
      altInput: true,
      altFormat: 'Y-m-d',
      altInputClass: 'w-full',
    },
  }),
  props: [
    'filter',
    'appliedFilters',
    'index',
  ],
  computed: {
    filterClass() {
      if (this.filter && this.filter.filter_class) {
        return this.filter.filter_class
      }

      return ''
    },
    defaultIsSelected() {
      return JSON.stringify(this.value) === JSON.stringify(this.filter.default)
    },
    filterValue() {
      return this.value
    },
  },
  methods: {
    changeFilter() {
      return this.$emit('change-filter', { [this.filterClass]: this.filterValue })
    },
    setInitialValue() {
      const presentFilterValue = this.appliedFilters[this.filterClass]

      if (presentFilterValue) {
        this.value = presentFilterValue
      } else if (this.filter.default) {
        this.value = this.filter.default
      }
    },
  },
  mounted() {
    this.setInitialValue()
  },
}
</script>
