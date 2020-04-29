<template>
  <div>
    <view-header>
      <template #heading>
        {{resourceName}}
      </template>

      <template #search>
        <input type="text" placeholder="search"/>
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
        @sort="sort"
        ></resource-table>

        <paginate
          v-show="totalPages > 0 && resources.length > 0"
          v-model="page"
          ref="paginate"
          :page-count="totalPages"
          :click-handler="changePage"
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
import URI from 'urijs'
import { Api } from '@/js/Avo'

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
  },
  methods: {
    setPage(page) {
      this.page = parseInt(page, 10)
    },
    async changePage(page) {
      this.isLoading = true

      this.$router.push({
        name: 'index',
        params: {
          resourceName: this.resourceName,
        },
        query: {
          page,
        },
      })
    },
    async getResources() {
      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}?page=${this.page}&sort_by=${this.sortBy}&sort_direction=${this.sortDirection}`)

      this.resources = data.resources
      this.totalPages = data.total_pages

      this.isLoading = false
    },
    changeSortDirection() {
      switch (this.sortDirection) {
        case '':
          this.sortDirection = 'desc'
          break
        case 'desc':
          this.sortDirection = 'asc'
          break
        case 'asc':
          this.sortDirection = ''
          this.sortBy = ''
          break
        default:
          this.sortDirection = ''
          break
      }
    },
    sort(by) {
      this.sortBy = by
      this.changeSortDirection()
    },
  },
  beforeRouteUpdate(to, from, next) {
    next()
    this.setPage(to.query.page)
  },
  watch: {
    page(page) {
      this.page = page
      this.getResources()
    },
    sortBy() {
      this.getResources()
    },
    sortDirection() {
      this.getResources()
    },
  },
  async mounted() {
    let page = 1

    try {
      page = URI(window.location.toString()).query(true).page
    // eslint-disable-next-line no-empty
    } catch (err) {}

    this.setPage(page)
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
