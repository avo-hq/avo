<template>
  <filter-wrapper :name="filter.name" :index="index">
    <select :name="filter.id"
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
    </select>
  </filter-wrapper>
</template>

<script>
import { HasInputAppearance } from '@avo-hq/avo-js'

export default {
  mixins: [HasInputAppearance],
  data: () => ({
    value: '',
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
