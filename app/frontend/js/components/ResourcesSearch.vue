<template>
  <div>
    <multiselect
      id="ajax"
      label="name"
      track-by="code"
      placeholder="Type to search"
      open-direction="bottom"
      :options="resources"
      :searchable="true"
      :loading="isLoading"
      :internal-search="false"
      :clear-on-select="true"
      :close-on-select="true"
      :options-limit="300"
      :limit="3"
      :limit-text="limitText"
      :max-height="600"
      :group-values="groupValues"
      :group-label="groupLabel"
      :hide-selected="true"
      @search-change="asyncFind"
      @select="select"
    >
      <template slot="tag" slot-scope="{ option, remove }">
        <span class="custom__tag"
          ><span>{{ option.name }}</span
          ><span class="custom__remove" @click="remove(option)">❌</span></span
        >
      </template>
      <span slot="noResult"
        >Oops! No elements found. Consider changing the search query.</span
      >
    </multiselect>
  </div>
</template>

<script>
import '~/vue-multiselect/dist/vue-multiselect.min.css'
import { Api } from '@/js/Avo'
import Multiselect from 'vue-multiselect'
import URI from 'urijs'
import debounce from 'lodash/debounce'
import isUndefined from 'lodash/isUndefined'

export default {
  components: { Multiselect },
  data: () => ({
    query: '',
    results: [],
    resources: [],
    isLoading: false,
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'global',
  ],
  computed: {
    groupValues() {
      return this.global ? 'resources' : null
    },
    groupLabel() {
      return this.global ? 'label' : null
    },
    isGlobal() {
      return !isUndefined(this.global)
    },
    queryUrl() {
      const url = new URI()

      if (this.isGlobal) {
        url.path('/avocado/avocado-api/search')
      } else {
        url.path(`/avocado/avocado-api/${this.resourceName}/search`)
      }

      const query = {
        q: this.query,
      }

      if (this.isGlobal) {
        if (!isUndefined(this.viaResourceName)) {
          // eslint-disable-next-line dot-notation
          query['via_resource_name'] = this.viaResourceName
        }
        if (!isUndefined(this.viaResourceId)) {
          // eslint-disable-next-line dot-notation
          query['via_resource_id'] = this.viaResourceId
        }
      }

      url.query(query)

      return url
    },
  },
  methods: {
    limitText(count) {
      return `and ${count} other resources`
    },
    asyncFind: debounce(function (query) {
      const vm = this
      this.query = query

      vm.isLoading = true
      Api.get(this.queryUrl)
        .then(({ data }) => {
          vm.resources = data.resources
          vm.isLoading = false
        })
    }, 300),
    select(resource) {
      setTimeout(() => {
        this.$router.push(resource.link)
      }, 1)
    },
  },
  mounted() { },
}
</script>

<style lang="postcss"></style>
