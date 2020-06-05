<template>
  <div class="relative w-full px-4 flex justify-between">
    <div></div>
    <button class="bg-blue-300 p-2 shadow rounded text-white" @click="toggleFiltersPanel"><FilterIcon class="h-8"/></button>
    <div class="absolute block inset-auto right-0 top-full rounded bg-white shadow min-w-300px mr-4 z-20" v-if="open">
      <div>
        <div class="bg-blue-600 text-white py-2 px-4">
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
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100">100</option>
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
// eslint-disable-next-line import/no-unresolved
import FilterIcon from '@/svgs/filter.svg?inline'
import HasInputAppearance from '@/js/mixins/has-input-appearance'

export default {
  components: { FilterIcon },
  mixins: [HasInputAppearance],
  data: () => ({
    open: false,
    localPerPage: 25,
  }),
  props: ['resourceName', 'resourceId', 'perPage', 'filters', 'appliedFilters'],
  computed: {},
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
  },
  mounted() {
    this.localPerPage = this.perPage
  },
}
</script>
