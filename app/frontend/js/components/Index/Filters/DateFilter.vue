<template>
  <filter-wrapper :name="filter.name" :index="index">
    <flat-pickr
      :name="filter.id"
      :id="filter.id"
      @on-change="changeFilter"
      ref="field-input"
      class="w-full"
      v-model="value"
      :config="flatpickrConfig"
      :placeholder="filter.filter_configuration.placeholder"
    />
  </filter-wrapper>
</template>

<script>
import '~/flatpickr/dist/flatpickr.css'
import { HasInputAppearance } from '@avo-hq/avo-js'
import IsFieldWrapper from '@/js/mixins/is-field-wrapper'
import flatPickr from 'vue-flatpickr-component'

export default {
  mixins: [HasInputAppearance, IsFieldWrapper],
  components: { flatPickr },
  data: () => ({
    value: '',
    flatpickrConfig: {
      dateFormat: 'Y-m-d',
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
      if (this.filterValue !== this.appliedFilters[this.filterClass]) {
        return this.$emit('change-filter', { [this.filterClass]: this.filterValue })
      }

      return null
    },
    setInitialValue() {
      const presentFilterValue = this.appliedFilters[this.filterClass]

      if (presentFilterValue) {
        this.value = presentFilterValue
      } else if (this.filter.default) {
        this.value = this.filter.default
      }
    },
    setInitialConfig() {
      // set flatpickr format
      this.flatpickrConfig.altFormat = this.filter.filter_configuration.picker_format

      // set input styling
      this.flatpickrConfig.altInputClass += ` ${this.inputClasses}`

      // set first day of the week
      this.flatpickrConfig.locale.firstDayOfWeek = this.filter.filter_configuration.first_day_of_week

      // set mode to range
      if (this.filter.filter_configuration.range) {
        this.flatpickrConfig.mode = 'range'
      }
    },
    focus() {
      // No support for this at the moment.
    },
  },
  mounted() {
    this.setInitialValue()
  },
  created() {
    this.setInitialConfig()
  },
}
</script>
