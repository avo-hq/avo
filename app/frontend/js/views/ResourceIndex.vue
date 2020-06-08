<template>
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
          >Create new {{resourceNameSingular | toLowerCase}}</router-link>
        </div>
      </div>
    </template>

    <template #content>
      <template>
        <div class="flex justify-between items-center py-4">
          <resources-filter
            @change-per-page="changePerPage"
            :per-page="perPage"
            :per-page-steps="perPageSteps"
            :filters="filters"
            :applied-filters="appliedFilters"
            @change-filter="changeFilter"
            :via-resource-name="viaResourceName"
          />
        </div>

        <div class="w-full overflow-auto min-h-28 flex flex-col">
          <loading-overlay class="relative" v-if="resources.length === 0 && isLoading"/>
          <div class="relative flex-1 flex" v-else>
            <loading-overlay v-if="isLoading" />

            <resource-table
              v-if="resources && resources.length > 0"
              :resources="resources"
              :resource-name="resourceName"
              :sort-by="sortBy"
              :sort-direction="sortDirection"
              :via-resource-name="viaResourceName"
              :via-resource-id="viaResourceId"
              @sort="changeSortBy"
              ></resource-table>

              <div class="flex-1 flex items-center justify-center" v-else>
                No {{resourceNamePlural | toLowerCase}} found
              </div>
          </div>

          <paginate
            v-show="totalPages > 1"
            v-model="page"
            ref="paginate"
            :page-count="totalPages"
            :click-handler="changePageFromPagination"
            :prev-text="'Prev'"
            :next-text="'Next'"
            :no-li-surround="true"
            container-class="avo-pagination flex justify-end px-4"
            page-class="pagination-button"
            page-link-class="button select-none rounded-none focus:outline-none"
            active-class="active"
            prev-link-class="button rounded-none focus:outline-none"
            next-link-class="button rounded-none focus:outline-none"
            class="py-4 select-none"
          ></paginate>
        </div>
      </template>
    </template>
  </panel>
</template>

<script>
import Api from '@/js/Api'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import URI from 'urijs'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  name: 'ResourceIndex',
  mixins: [DealsWithResourceLabels],
  data: () => ({
    resources: [],
    totalPages: 0,
    page: 0,
    perPage: 25,
    meta: {
      per_page_steps: [],
    },
    sortBy: '',
    sortDirection: '',
    isLoading: true,
    filters: [],
    appliedFilters: {},
    oldQueryUrl: '',
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
  ],
  computed: {
    newQueryParams() {
      return {
        name: this.viaResourceName ? 'show' : 'index',
        params: this.params,
        query: this.query,
      }
    },
    params() {
      return {
        resourceName: this.viaResourceName ? this.viaResourceName : this.resourceName,
        resourceId: this.viaResourceId ? this.viaResourceId : null,
      }
    },
    query() {
      const params = {}

      if (!this.paramCanBeOmitted(this.page, 1)) {
        if (this.viaResourceName) {
          params[this.uriParam('apge')] = this.page
        } else {
          params.page = this.page
        }
      }

      if (!this.paramCanBeOmitted(this.perPage, 25)) {
        if (this.viaResourceName) {
          params[this.uriParam('per_page')] = this.perPage
        } else {
          // eslint-disable-next-line camelcase
          params.per_page = this.perPage
        }
      }

      // if (Object.keys(this.appliedFilters).length > 0) {
      //   params.filters = this.encodedFilters
      // } else {
      //   delete params.filters
      // }
      if (Object.keys(this.appliedFilters).length > 0) {
        if (this.viaResourceName) {
          params[this.uriParam('filters')] = this.encodedFilters
        } else {
          // eslint-disable-next-line camelcase
          params.filters = this.encodedFilters
        }
      }

      if (this.sortBy !== '') {
        if (this.viaResourceName) {
          params[this.uriParam('sort_by')] = this.sortBy
        } else {
          // eslint-disable-next-line camelcase
          params.sort_by = this.sortBy
        }
      }

      if (this.sortDirection !== '') {
        if (this.viaResourceName) {
          params[this.uriParam('sort_direction')] = this.sortDirection
        } else {
          // eslint-disable-next-line camelcase
          params.sort_direction = this.sortDirection
        }
      }

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
    perPageSteps() {
      return this.meta.per_page_steps
    },
  },
  methods: {
    updateQueryParams() {
      this.$router.push(this.newQueryParams)
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
      if (this.oldQueryUrl === this.queryUrl) return
      this.oldQueryUrl = this.queryUrl

      this.isLoading = true

      const { data } = await Api.get(this.queryUrl)

      this.resources = data.resources
      this.totalPages = data.total_pages
      this.meta = data.meta

      this.isLoading = false
    },
    async getFilters() {
      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}/filters`)

      this.filters = data.filters
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
    async initQueryParams() {
      this.setPage(URI(window.location.toString()).query(true)[this.uriParam('page')])
      this.setPerPage(URI(window.location.toString()).query(true)[this.uriParam('per_page')])
      this.setSortBy(URI(window.location.toString()).query(true)[this.uriParam('sort_by')])
      this.setSortDirection(URI(window.location.toString()).query(true)[this.uriParam('sort_direction')])
      const filters = URI(window.location.toString()).query(true)[this.uriParam('filters')]
      if (filters) this.setFilterValue(JSON.parse(atob(filters)))

      await this.getResources()
    },
    paramCanBeOmitted(param, defaultValue) {
      return param === '' || Number.isNaN(param) || isUndefined(param) || isNull(param) || param === defaultValue
    },
    uriParam(param) {
      if (this.viaResourceName) return `${this.resourceName}_${param}`

      return param
    },
  },
  watch: {
    $route: 'getResources',
  },
  async created() {
    this.getFilters()
    this.initQueryParams()
  },
}
</script>

<style slang="postcss">
/* @todo: fix loaders to support lang= */
.avo-pagination {
  a {
    @apply shadow-md;
  }
  a.active {
    @apply bg-gray-300 border-gray-300;
  }
  a.disabled {
    @apply text-gray-500;

    &:hover {
      @apply bg-white;
    }
  }
}
</style>
