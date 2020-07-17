<template>
  <div class="relative w-full flex justify-between z-30" v-if="hasFilters">
    <a-button color="gray" class="focus:outline-none" @click="toggleFiltersPanel">
      <filter-icon class="h-4 mr-2" data-button="resource-filters" /> Filters
    </a-button>
    <div v-on-clickaway="onClickAway"
      class="absolute block inset-auto right-0 top-full bg-white min-w-300px mr-4 z-20 shadow-row rounded-lg overflow-hidden"
      v-if="open"
    >
      <div v-if="!viaResourceName">
        <filter-wrapper name="Per page">
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
        </filter-wrapper>
      </div>
      <template v-for="(filter, index) in filters">
        <component :key="index"
          :is="filter.component"
          :index="index"
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
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
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
  computed: {
    hasFilters() {
      return this.filters.length > 0
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
