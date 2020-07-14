<template>
  <div>
    <div class="bg-gray-600 text-white py-2 px-4 text-sm">
      {{filter.name}}
    </div>
    <div class="p-4">
      <div class="flex items-center">
        <div class="space-y-2">
          <template v-for="(name, value, index) in filter.options">
            <div
              :key="index"
              @click="toggleOption(value)"
            >
              <input
                type="checkbox"
                :id="name"
                :name="name"
                :checked="optionToggled(value)"
              />
              <label>{{ name }}</label>
            </div>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  mixins: [HasInputAppearance],
  data: () => ({
    selected: [],
  }),
  props: [
    'filter',
    'appliedFilters',
  ],
  computed: {
    filterClass() {
      if (this.filter && this.filter.filter_class) {
        return this.filter.filter_class
      }

      return ''
    },
    filterValue() {
      const value = {}

      Object.keys(this.filter.options).forEach((option) => {
        value[option] = this.optionToggled(option)
      })

      return value
    },
  },
  methods: {
    toggleOption(option) {
      if (this.optionToggled(option)) {
        this.selected = this.selected.filter((currentOption) => currentOption !== option)
      } else {
        this.selected.push(option)
      }

      this.changeFilter()
    },
    optionToggled(option) {
      return this.selected.indexOf(option) > -1
    },
    changeFilter() {
      return this.$emit('change-filter', { [this.filterClass]: this.filterValue })
    },
    applySelection(selection) {
      Object.keys(selection).forEach((option) => {
        if (selection[option]) {
          this.selected.push(option)
        }
      })
    },
    setInitialValue() {
      const presentFilterValue = this.appliedFilters[this.filterClass]

      if (presentFilterValue) {
        this.applySelection(presentFilterValue)
      } else if (this.filter.default) {
        this.applySelection(this.filter.default)
      }
    },
  },
  mounted() {
    this.setInitialValue()
  },
}
</script>
