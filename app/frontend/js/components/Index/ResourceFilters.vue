<template>
  <div class="relative w-full flex justify-between z-30" v-if="hasFilters">
    <a-button color="gray" class="focus:outline-none" @click="togglePanel">
      <filter-icon class="h-4 mr-2" data-button="resource-filters" /> {{ $t('avo.filters') }}
    </a-button>
    <div v-on-clickaway="onClickAway"
      class="absolute block inset-auto right-0 top-full bg-white min-w-300px mt-2 z-20 shadow-context rounded-xl"
      v-if="open"
    >
      <div v-if="!viaResourceName">
        <filter-wrapper :name="$t('avo.per_page')">
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
      <div class="p-4 border-gray-300 border-t">
        <a-button color="gray"
          class="w-full"
          :disabled="resetDisabled"
          @click="resetFilters"
          v-text="'Reset filters'"
        />
      </div>

    </div>
  </div>
</template>

<script>
import { HasInputAppearance } from '@avo-hq/avo-js'
import { mixin as clickaway } from 'vue-clickaway'

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
    perPageSteps: {},
  },
  computed: {
    hasFilters() {
      return this.filters.length > 0
    },
    resetDisabled() {
      if (this.$route.query.filters === undefined) return true

      return false
    },
  },
  methods: {
    togglePanel() {
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
    resetFilters() {
      this.$emit('reset-filters')
      this.togglePanel()
    },
  },
  mounted() {
    this.localPerPage = this.perPage
  },
}
</script>
