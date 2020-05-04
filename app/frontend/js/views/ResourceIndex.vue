<template>
  <div>
    <view-header>
      <template #heading>
        {{resourceName}}
      </template>

      <template #search>
        <resources-search :resource-name="resourceName" />
      </template>
      <template #tools>

        <router-link
          :to="{
            name: 'new',
            params: {
              resourceName: resourceName,
            },
          }"
          class="button"
        >Create new {{resourceNameSingular}}</router-link>
      </template>
    </view-header>

    <div class="flex justify-between items-center mb-4">
    </div>

    <panel>
      <div v-if="isLoading">
        loading
      </div>
      <resource-table
        v-else
        :resources="resources"
        :resource-name="resourceName"
        :sort-by="sortBy"
        :sort-direction="sortDirection"
        @sort="changeSortBy"
        ></resource-table>

        <paginate
          v-show="totalPages > 0 && resources.length > 0"
          v-model="page"
          ref="paginate"
          :page-count="totalPages"
          :click-handler="changePageFromPagination"
          :prev-text="'Prev'"
          :next-text="'Next'"
          container-class="avo-pagination flex justify-end px-4"
          page-class="pagination-button"
          page-link-class="button"
          active-class="active"
          prev-link-class="button"
          next-link-class="button"
        ></paginate>
    </panel>
  </div>
</template>

<script>
import { Api } from '@/js/Avo'
import URI from 'urijs'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  name: 'ResourceIndex',
  data: () => ({
    resources: [],
    totalPages: 0,
    page: 0,
    sortBy: '',
    sortDirection: '',
    isLoading: true,
  }),
  props: [
    'resourceName',
  ],
  computed: {
    resourceNameSingular() {
      if (this.resources && this.resources.length > 0) {
        return this.resources[0].resource_name_singular
      }

      return ''
    },
    queryParams() {
      const params = {}

      if (this.page === '' || Number.isNaN(this.page) || isUndefined(this.page) || isNull(this.page) || this.page === 1) {
        delete params.page
      } else {
        params.page = this.page
      }

      // eslint-disable-next-line camelcase
      if (this.sortBy !== '') params.sort_by = this.sortBy
      // eslint-disable-next-line camelcase
      if (this.sortDirection !== '') params.sort_direction = this.sortDirection

      return params
    },
  },
  methods: {
    updateQueryParams() {
      this.$router.push({
        name: 'index',
        params: {
          resourceName: this.resourceName,
        },
        query: this.queryParams,
      })
    },
    changePageFromPagination(page) {
      this.setPage(page)
      this.updateQueryParams()
    },
    async getResources() {
      this.isLoading = true

      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}?page=${this.page}&sort_by=${this.sortBy}&sort_direction=${this.sortDirection}`)

      this.resources = data.resources
      this.totalPages = data.total_pages

      this.isLoading = false
    },
    changeSortDirection(by) {
      if (this.sortBy !== '' && this.sortBy !== by) {
        this.sortDirection = 'desc'

        return
      }

      switch (this.sortDirection) {
        case '':
          this.sortDirection = 'desc'
          break
        case 'desc':
          this.sortDirection = 'asc'
          break
        case 'asc':
          this.sortDirection = ''
          break
        default:
          this.sortDirection = ''
          break
      }
    },
    changeSortBy(by) {
      const newBy = this.sortDirection === 'asc' ? '' : by

      this.changeSortDirection(by)
      this.setSortBy(newBy)
      this.updateQueryParams()
    },
    setPage(page) {
      this.page = isUndefined(page) ? 1 : parseInt(page, 10)
    },
    setSortBy(by) {
      this.sortBy = isUndefined(by) ? '' : by
    },
    setSortDirection(direction) {
      this.sortDirection = isUndefined(direction) ? '' : direction
    },
    initQueryParams() {
      let page = 1
      let sortBy = ''
      let sortDirection = ''

      page = URI(window.location.toString()).query(true).page
      sortBy = URI(window.location.toString()).query(true).sort_by
      sortDirection = URI(window.location.toString()).query(true).sort_direction

      this.setPage(page)
      this.setSortBy(sortBy)
      this.setSortDirection(sortDirection)

      this.getResources()
    },
  },
  beforeRouteUpdate(to, from, next) {
    next()

    this.getResources()
  },
  async mounted() {
    this.initQueryParams()
  },
}
</script>

<style slang="postcss">
/* @todo: fix loaders to support lang= */
.avo-pagination {
  .active {
    a {
      @apply bg-indigo-400;
    }
  }
}
</style>
