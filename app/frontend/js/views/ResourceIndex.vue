<template>
  <panel>
    <template #heading>
      {{resourceNamePlural}}
    </template>

    <template #tools>
      <div class="flex justify-end items-center mb-6 w-full">
        <div class="mr-2">
          <resource-actions
            :resource-name="resourceName"
            :resource-ids="selectedResources"
            :actions="actions"
            v-if="resources.length > 0"
          />
        </div>
        <div>
          <a-button
            color="indigo"
            href="javascript:void(0);"
            @click="showAttachModal"
            v-if="relationship === 'has_and_belongs_to_many'"
          >
            <view-grid-add-icon class="h-4 mr-1" />Attach {{resourceNameSingular | toLowerCase}}
          </a-button>
          <a-button
            is="a-button"
            :to="{
              name: 'new',
              params: {
                resourceName: resourcePath,
              },
              query: {
                viaRelationship: fieldId,
                viaResourceName: viaResourceName,
                viaResourceId: viaResourceId,
              },
            }"
            v-else-if="canCreate"
          ><plus-icon class="h-4 mr-1"/>Create new {{resourceNameSingular | toLowerCase}}</a-button>
        </div>
      </div>
    </template>

    <template #content>
      <template>
        <div class="flex justify-between py-6">
          <div class="flex items-center px-6 w-64">
            <resources-search
              :resource-name="resourceName"
              :via-resource-name="viaResourceName"
              :via-resource-id="viaResourceId"
              v-if="resources.length > 0"
            />
          </div>
          <div class="flex justify-end items-center px-6 space-x-3">
            <a-button @click="changeViewType('table')"
              color="blue"
              v-if="availableViewTypes.includes('table') && viewType !== 'table'"
            >
              <view-list-icon class="h-4 mr-1" /> Table View
            </a-button>
            <a-button @click="changeViewType('grid')"
              color="blue"
              v-if="availableViewTypes.includes('grid') && viewType !== 'grid'"
            >
              <view-grid-icon class="h-4 mr-1" /> Grid View
            </a-button>
            <resource-filters
              v-if="!viaResourceName"
              :via-resource-name="viaResourceName"
              :per-page="perPage"
              :per-page-steps="perPageSteps"
              :filters="filters"
              :applied-filters="appliedFilters"
              @change-filter="changeFilter"
              @change-per-page="changePerPage"
              @reset-filters="resetFilters"
            />
          </div>
        </div>

        <loading-overlay class="relative" v-if="viewType === '' && isLoading"/>

        <div class="w-full overflow-auto min-h-28 flex flex-col" v-if="viewType === 'table'">
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
              :field="field"
              :total-pages="totalPages"
              @sort="changeSortBy"
              @resource-deleted="getResources(true)"
            />

            <empty-state
              :resource-name="resourceNamePlural"
              :via-resource-name="viaResourceName"
              v-else
            />
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
            container-class="avo-pagination justify-end flex px-4 space-x-2"
            page-class="pagination-button"
            active-class="text-blue-700 bg-gray-400"
            :page-link-class="`${paginationClasses} select-none`"
            :next-link-class="`${paginationClasses}`"
            :prev-link-class="`${paginationClasses}`"
            class="py-6 select-none"
          />
        </div>
      </template>
    </template>

    <template #bare-content>
      <div v-if="viewType === 'grid'">
        <resource-grid
          v-if="resources && resources.length > 0"
          :resources="resources"
          :resource-name="resourceName"
          :sort-by="sortBy"
          :sort-direction="sortDirection"
          :via-resource-name="viaResourceName"
          :via-resource-id="viaResourceId"
          :field="field"
          @sort="changeSortBy"
          @resource-deleted="getResources(true)"
        />

        <div class="bg-white rounded-xl shadow-xl" v-else>
          <empty-state
            :resource-name="resourceNamePlural"
            :via-resource-name="viaResourceName"
          />
        </div>

        <div class="bg-white rounded-lg shadow-xl mt-6">
          <paginate
            v-show="totalPages > 1"
            v-model="page"
            ref="paginate"
            :page-count="totalPages"
            :click-handler="changePageFromPagination"
            :prev-text="'Prev'"
            :next-text="'Next'"
            :no-li-surround="true"
            container-class="avo-pagination justify-end flex px-4 space-x-2"
            page-class="pagination-button"
            active-class="text-blue-700 bg-gray-400"
            :page-link-class="`${paginationClasses} select-none`"
            :next-link-class="`${paginationClasses}`"
            :prev-link-class="`${paginationClasses}`"
            class="py-6 select-none"
          />
        </div>
      </div>
    </template>
  </panel>
</template>

<script>
import { mapMutations, mapState } from 'vuex'
import Api from '@/js/Api'
import AttachModal from '@/js/components/AttachModal.vue'
import Avo from '@/js/Avo'
import Bus from '@/js/Bus'
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import LoadsActions from '@/js/mixins/loads-actions'
import URI from 'urijs'
import isNull from 'lodash/isNull'
import isUndefined from 'lodash/isUndefined'

export default {
  name: 'ResourceIndex',
  mixins: [DealsWithResourceLabels, DealsWithHasManyRelations, LoadsActions],
  data: () => ({
    resources: [],
    totalPages: 0,
    page: 0,
    perPage: 24,
    meta: {
      // eslint-disable-next-line camelcase
      per_page_steps: [],
    },
    sortBy: '',
    sortDirection: '',
    isLoading: true,
    filters: [],
    appliedFilters: {},
    oldQueryUrl: '',
    paginationClasses: 'rounded-lg focus:outline-none px-3 py-1 text-sm text-gray-600 font-semibold bg-gray-300 hover:bg-gray-400 shadow-md',
    viewType: '',
    availableViewTypes: [],
    rootPath: '/avo',
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'field',
  ],
  computed: {
    ...mapState('index', [
      'selectedResources',
    ]),
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
          params[this.uriParam('page')] = this.page
        } else {
          params.page = this.page
        }
      }

      if (!this.paramCanBeOmitted(this.perPage, 24)) {
        if (this.viaResourceName) {
          params[this.uriParam('per_page')] = this.perPage
        } else {
          // eslint-disable-next-line camelcase
          params.per_page = this.perPage
        }
      }

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

      if (this.viewType !== '') {
        if (this.viaResourceName) {
          params[this.uriParam('view_type')] = this.viewType
        } else {
          // eslint-disable-next-line camelcase
          params.view_type = this.viewType
        }
      }

      return params
    },
    encodedFilters() {
      if (Object.keys(this.appliedFilters).length === 0) return null

      return btoa(JSON.stringify(this.appliedFilters))
    },
    queryUrl() {
      const url = new URI()
      url.path(`${Avo.rootPath}/avo-api/${this.resourcePath}`)

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
          via_relationship: this.fieldId,
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
    fieldId() {
      return this.field ? this.field.id : undefined
    },
    canCreate() {
      if (this.meta && this.meta.authorization) return this.meta.authorization.create

      return true
    },
  },
  methods: {
    ...mapMutations('index', [
      'clearSelectedResources',
    ]),
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
    resetFilters() {
      this.appliedFilters = {}
      this.updateQueryParams()
    },
    changePageFromPagination(page) {
      this.setPage(page)
      this.updateQueryParams()
    },
    changeViewType(viewType) {
      if (viewType === this.viewType) return

      this.setViewType(viewType)
      this.updateQueryParams()
    },
    async getResources(force = false) {
      if (this.oldQueryUrl === this.queryUrl && !force) return

      this.oldQueryUrl = this.queryUrl
      this.isLoading = true

      const { data } = await Api.get(this.queryUrl)

      this.resources = data.resources
      this.totalPages = data.total_pages
      this.meta = data.meta
      this.availableViewTypes = data.meta.available_view_types

      // Set this only on first page load
      if (this.viewType === '') this.setViewType(data.meta.default_view_type)

      Bus.$emit('resourcesLoaded', this.resources)

      this.isLoading = false
    },
    async getFilters() {
      const { data } = await Api.get(`${Avo.rootPath}/avo-api/${this.resourcePath}/filters`)

      if (data && data.filters) this.filters = data.filters
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
    setViewType(viewType) {
      this.viewType = isUndefined(viewType) ? '' : viewType
    },
    setPerPage(perPage) {
      this.perPage = isUndefined(perPage) ? 24 : parseInt(perPage, 10)
    },
    setSortBy(by) {
      this.sortBy = isUndefined(by) ? '' : by
    },
    setSortDirection(direction) {
      this.sortDirection = isUndefined(direction) ? '' : direction
    },
    setFilterValue(args) {
      Object.keys(args).forEach((filterClassName) => {
        const value = args[filterClassName]

        if (this.isDefaultValueForFilter(filterClassName, value)) {
          this.$delete(this.appliedFilters, filterClassName)
        } else {
          this.$set(this.appliedFilters, filterClassName, value)
        }
      })
    },
    isDefaultValueForFilter(filterClassName, value) {
      const currentFilter = this.filters.find((filter) => filter.filter_class === filterClassName)

      if (!currentFilter) return false

      return JSON.stringify(currentFilter.default) === JSON.stringify(value)
    },
    async initQueryParams() {
      this.setPage(URI(window.location.toString()).query(true)[this.uriParam('page')])
      this.setPerPage(URI(window.location.toString()).query(true)[this.uriParam('per_page')])
      this.setSortBy(URI(window.location.toString()).query(true)[this.uriParam('sort_by')])
      this.setSortDirection(URI(window.location.toString()).query(true)[this.uriParam('sort_direction')])
      this.setViewType(URI(window.location.toString()).query(true)[this.uriParam('view_type')])
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
    async getOptions() {
      const { data } = await Api.get(`${Avo.rootPath}/avo-api/${this.resourceName}?for_relation=${this.relationship}`)

      return data.resources
    },
    async attachOption(option, another = false) {
      const { data } = await Api.post(`${Avo.rootPath}/avo-api/${this.viaResourceName}/${this.viaResourceId}/attach/${this.resourceName}/${option}`)

      const { success } = data

      if (success) {
        if (!another) {
          this.$modal.hideAll()
        }

        await this.getResources(true)
      }
    },
    async showAttachModal() {
      this.$modal.show(AttachModal, {
        heading: `Select a ${this.resourceNameSingular.toLowerCase()} to attach`,
        getOptions: this.getOptions,
        attachAction: this.attachOption,
      })
    },
    queryFiltersChanged() {
      const filters = URI(window.location.toString()).query(true)[this.uriParam('filters')]

      if (filters) {
        this.setFilterValue(JSON.parse(atob(filters)))
      } else {
        this.appliedFilters = {}
      }
    },
  },
  watch: {
    '$route.query.filters': 'queryFiltersChanged',
    $route() {
      this.getResources()
    },
  },
  async created() {
    this.addToBus(this.getFilters)
    this.addToBus(this.initQueryParams)
  },
  mounted() {
    Bus.$on('reload-resources', () => this.getResources(true))
  },
  destroyed() {
    this.clearSelectedResources()

    Bus.$off('reload-resources')
  },
}
</script>

<style slang="postcss">
/* @todo: fix loaders to support lang= */
.avo-pagination {
  a.disabled {
    @apply text-gray-500;

    &:hover {
      @apply bg-gray-300;
    }
  }
}
</style>
