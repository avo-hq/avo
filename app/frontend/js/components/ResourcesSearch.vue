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
import Turbolinks from 'turbolinks'
import debounce from 'lodash/debounce'

export default {
  components: { Multiselect },
  data: () => ({
    results: [],
    resources: [],
    isLoading: false,
  }),
  props: ['resourceName', 'global'],
  computed: {
    groupValues() {
      return this.global ? 'resources' : null
    },
    groupLabel() {
      return this.global ? 'label' : null
    },
  },
  methods: {
    limitText(count) {
      return `and ${count} other resources`
    },
    asyncFind: debounce(function (query) {
      const vm = this

      vm.isLoading = true
      Api.get(this.queryUrl(query))
        .then(({ data }) => {
          vm.resources = data.resources
          vm.isLoading = false
        })
    }, 300),
    queryUrl(query) {
      if (this.global) {
        return `/avocado/avocado-api/search?q=${query}`
      }

      return `/avocado/avocado-api/${this.resourceName}/search?q=${query}`
    },
    select(resource) {
      setTimeout(() => {
        Turbolinks.visit(resource.link)
      }, 1)
    },
  },
  mounted() { },
}
</script>

<style lang="postcss"></style>
