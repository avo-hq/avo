<template>
  <div>
    <panel>
      <template #heading>
        {{resourceNamePlural}}
      </template>

      <template #tools>
        <div class="flex justify-between items-center mb-4 w-full">
          <div>
            <resources-search
              :resource-name="resourceName"
              :via-resource-name="viaResourceName"
              :via-resource-id="viaResourceId"
              />
          </div>
          <div>
            <router-link
              :to="{
                name: 'new',
                params: {
                  resourceName: resourceName,
                },
              }"
              class="button"
            >Create new {{resourceNameSingular}}</router-link>
          </div>
        </div>
      </template>

      <template #content>
        <div v-if="isLoading">
          loading
        </div>

        <div v-else>
          <div class="flex justify-between items-center mb-4">
            <resources-filter
              @change-per-page="changePerPage"
              :per-page="perPage"
              :filters="filters"
              :applied-filters="appliedFilters"
              @change-filter="changeFilter"
            />
          </div>

          <resource-table
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
        </div>

      </template>
    </panel>
  </div>
</template>

<script>
import Api from '@/js/Api'
import URI from 'urijs'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  name: 'ResourceIndex',
  data: () => ({
    resources: [],
    totalPages: 0,
    page: 0,
    perPage: 25,
    sortBy: '',
    sortDirection: '',
    isLoading: true,
    filters: [],
    appliedFilters: {},
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
  ],
  computed: {
    resourceNameSingular() {
      if (this.resources && this.resources.length > 0) {
        return this.resources[0].resource_name_singular
      }

      return ''
    },
    resourceNamePlural() {
      if (this.resources && this.resources.length > 0) {
        return this.resources[0].resource_name_plural
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

      if (this.perPage === '' || Number.isNaN(this.perPage) || isUndefined(this.perPage) || isNull(this.perPage) || this.perPage === 25) {
        delete params.per_page
      } else {
        // eslint-disable-next-line camelcase
        params.per_page = this.perPage
      }

      if (Object.keys(this.appliedFilters).length > 0) {
        console.log(this.appliedFilters)
        params.filters = this.encodedFilters
      } else {
        delete params.filters
      }

      // eslint-disable-next-line camelcase
      if (this.sortBy !== '') params.sort_by = this.sortBy
      // eslint-disable-next-line camelcase
      if (this.sortDirection !== '') params.sort_direction = this.sortDirection

      return params
    },
    encodedFilters() {
      return btoa(JSON.stringify(this.appliedFilters))
    },
    queryUrl() {
      const url = new URI()
      url.path(`/avocado/avocado-api/${this.resourceName.toLowerCase()}`)

      /* eslint-disable camelcase */
      let query = {
        filters: this.encodedFilters,
        page: this.page,
        per_page: this.perPage,
        sort_by: this.sortBy,
        sort_direction: this.sortDirection,
      }

      if (this.viaResourceName) {
        query = {
          ...query,
          via_resource_name: this.viaResourceName.toLowerCase(),
          via_resource_id: this.viaResourceId,
        }
      }
      /* eslint-enable camelcase */

      url.query(query)

      return url.toString()
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
    changeFilter(args) {
      this.setFilterValue(args)
      this.updateQueryParams()
    },
    changePerPage(perPage) {
      this.setPerPage(perPage)
      this.updateQueryParams()
    },
    changePageFromPagination(page) {
      this.setPage(page)
      this.updateQueryParams()
    },
    async getResources() {
      this.isLoading = true

      const { data } = await Api.get(this.queryUrl)

      this.resources = data.resources
      this.totalPages = data.total_pages

      this.isLoading = false
    },
    async getFilters() {
      this.isLoading = true

      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}/filters`)

      this.filters = data.filters
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
    setPerPage(perPage) {
      this.perPage = isUndefined(perPage) ? 25 : parseInt(perPage, 10)
    },
    setSortBy(by) {
      this.sortBy = isUndefined(by) ? '' : by
    },
    setSortDirection(direction) {
      this.sortDirection = isUndefined(direction) ? '' : direction
    },
    setFilterValue(args) {
      Object.keys(args).forEach((filterClass) => {
        const value = args[filterClass]

        if (value === '' || value === '-') {
          this.$delete(this.appliedFilters, filterClass)
        } else {
          this.$set(this.appliedFilters, filterClass, value)
        }
      })
    },
    initQueryParams() {
      let page = 1
      let perPage = 25
      let sortBy = ''
      let sortDirection = ''
      let filters = ''

      page = URI(window.location.toString()).query(true).page
      perPage = URI(window.location.toString()).query(true).per_page
      sortBy = URI(window.location.toString()).query(true).sort_by
      sortDirection = URI(window.location.toString()).query(true).sort_direction
      filters = URI(window.location.toString()).query(true).filters

      this.setPage(page)
      this.setPerPage(perPage)
      this.setSortBy(sortBy)
      this.setSortDirection(sortDirection)
      if (filters) this.setFilterValue(JSON.parse(atob(filters)))

      this.getResources()
    },
  },
  beforeRouteUpdate(to, from, next) {
    next()

    this.getResources()
  },
  async mounted() {
    this.getFilters()
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
