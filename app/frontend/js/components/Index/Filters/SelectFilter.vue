<template>
  <div>
    <div class="bg-blue-600 text-white py-2 px-4">
      {{filter.name}}
    </div>
    <div class="p-4">
      <select name="per_page"
        id="per_page"
        @change="changeFilter"
        v-model="value"
        :class="inputClasses"
        class="select-input w-full"
      >
        <option value="">-</option>
        <option v-for="(value, name) in filter.options" :value="name" v-text="value" :key="name"></option>
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
  },
  methods: {
    changeFilter() {
      const args = {}
      args[this.filter.filter_class] = this.value

      this.$emit('change-filter', args)
    },
  },
  mounted() {
    const newFilterValue = this.appliedFilters[this.filterClass]
    if (newFilterValue) {
      this.value = newFilterValue
    }
  },
}
</script>
