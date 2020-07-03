<template>
  <div>
    <div class="bg-blue-600 text-white py-2 px-4">
      {{filter.name}}
    </div>
    <div class="p-4">
      <select :name="filter.id"
        :id="filter.id"
        @change="changeFilter"
        v-model="value"
        :class="inputClasses"
        class="select-input w-full"
      >
        <option value="">—</option>
        <option v-for="(value, name) in filter.options"
          :value="name"
          v-text="value"
          :key="name"/>
      </select>
    </div>
  </div>
</template>

<script>
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [HasInputAppearance],
  data: () => ({
    value: '',
  }),
  props: ['filter', 'appliedFilters'],
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
