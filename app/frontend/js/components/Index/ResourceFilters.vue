<template>
  <div class="relative w-full px-4 flex justify-between z-30">
    <div></div>
    <button class="bg-gray-500 p-2 shadow rounded text-white" @click="toggleFiltersPanel">
      <FilterIcon class="h-8" data-button="resource-filters" />
    </button>
    <div class="absolute block inset-auto right-0 top-full rounded bg-white shadow min-w-300px mr-4 z-20"
      v-if="open"
      v-on-clickaway="onClickAway"
    >
      <div v-if="!viaResourceName">
        <div class="bg-gray-600 text-white py-2 px-4 text-sm">
          Per page
        </div>
        <div class="p-4">
          <select name="per_page"
            id="per_page"
            @change="changePerPage"
            v-model="localPerPage"
            :class="inputClasses"
            class="select-input w-full"
          >
            <option v-for="step in perPageSteps"
              :key="step"
              :value="step"
              v-text="step"
            ></option>
          </select>
        </div>
      </div>
      <template v-for="(filter, index) in filters">
        <component :key="index"
          :is="filter.component"
          :filter="filter"
          :applied-filters="appliedFilters"
          @change-filter="changeFilter"
        ></component>
      </template>
    </div>
  </div>
</template>

<script>
import { mixin as clickaway } from 'vue-clickaway'
import FilterIcon from '@/svgs/filter.svg?inline'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  components: { FilterIcon },
  mixins: [HasInputAppearance, clickaway],
  data: () => ({
    open: false,
    localPerPage: 24,
  }),
  props: {
    resourceName: {},
    resourceId: {},
    viaResourceName: {},
    perPage: {},
    filters: {},
    appliedFilters: {},
    perPageSteps: {
      default: () => ([24, 48, 72]),
    },
  },
  methods: {
    toggleFiltersPanel() {
      this.open = !this.open
    },
    changePerPage() {
      this.$emit('change-per-page', this.localPerPage)
    },
    changeFilter(args) {
      this.$emit('change-filter', args)
    },
    onClickAway() {
      this.open = false
    },
  },
  mounted() {
    this.localPerPage = this.perPage
  },
}
</script>
