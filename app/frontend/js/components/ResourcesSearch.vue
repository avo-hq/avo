<template>
  <div>
    <multiselect
      label="name"
      placeholder="Type to search"
      :options="options"
      :searchable="true"
      :loading="isLoading"
      :internal-search="false"
      :clear-on-select="false"
      :close-on-select="false"
      :options-limit="300"
      :limit="3"
      :limit-text="limitText"
      :max-height="300"
      :group-values="groupValues"
      :group-label="groupLabel"
      @search-change="asyncFind"
      @select="select"
      :value="value"
      :show-labels="false"
      :allow-empty="true"
    >
      <template slot="tag" slot-scope="{ option, remove }">
        <span class="custom__tag"><span>11{{ option.name }}</span><span class="custom__remove" @click="remove(option)">❌</span></span
        >
      </template>
      <span slot="noResult">Oops! Nothing found...</span>
    </multiselect>
  </div>
</template>

<script>
import '~/vue-multiselect/dist/vue-multiselect.min.css'
import Api from '@/js/Api'
import Bus from '@/js/Bus'
import Multiselect from 'vue-multiselect'
import URI from 'urijs'
import debounce from 'lodash/debounce'
import isUndefined from 'lodash/isUndefined'

export default {
  components: { Multiselect },
  data: () => ({
    query: '',
    results: [],
    options: [],
    isLoading: false,
    value: {},
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'global',
    'single',
    'searchValue',
    'fieldId',
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
          vm.options = data.resources
          vm.isLoading = false
        })
    }, 300),
    select(resource) {
      if (this.single) {
        this.value = resource
        this.$emit('select', resource)
      } else {
        setTimeout(() => {
          this.$router.push(resource.link)
        }, 1)
      }
    },
    clearSelection() {
      this.value = {}
    },
  },
  mounted() {
    this.value = this.searchValue

    if (this.fieldId) Bus.$on(`clearSearchSelection${this.fieldId}`, this.clearSelection)
  },
  destroyed() {
    if (this.fieldId) Bus.$off(`clearSearchSelection${this.fieldId}`)
  },
}
</script>

<style lang="postcss"></style>
