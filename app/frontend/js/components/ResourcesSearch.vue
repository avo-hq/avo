<template>
  <div>
    <multiselect
      v-model="selectedCountries"
      id="ajax"
      label="name"
      track-by="code"
      placeholder="Type to search"
      open-direction="bottom"
      :options="countries"
      :multiple="true"
      :searchable="true"
      :loading="isLoading"
      :internal-search="false"
      :clear-on-select="false"
      :close-on-select="false"
      :options-limit="300"
      :limit="3"
      :limit-text="limitText"
      :max-height="600"
      :show-no-results="false"
      :hide-selected="true"
      @search-change="asyncFind"
    >
      <template slot="tag" slot-scope="{ option, remove }">
        <span class="custom__tag"
          ><span>{{ option.name }}</span
          ><span class="custom__remove" @click="remove(option)">❌</span></span
        >
      </template>
      <template slot="clear" slot-scope="props">
        <div
          class="multiselect__clear"
          v-if="selectedCountries.length"
          @mousedown.prevent.stop="clearAll(props.search)"
        ></div>
      </template>
      <span slot="noResult"
        >Oops! No elements found. Consider changing the search query.</span
      >
    </multiselect>
    <pre class="language-json"><code>{{ selectedCountries  }}</code></pre>
  </div>
</template>

<script>
import '~/vue-multiselect/dist/vue-multiselect.min.css'
import { Api } from '@/js/Avo'
import Multiselect from 'vue-multiselect'

export default {
  components: { Multiselect },
  data: () => ({
    results: [],
    selectedCountries: [],
    countries: [],
    isLoading: false,
  }),
  props: ['resourceName'],
  computed: {},
  methods: {
    limitText(count) {
      return `and ${count} other countries`
    },
    asyncFind(query) {
      this.isLoading = true
      this.ajaxFindCountry(query).then((response) => {
        this.countries = response
        this.isLoading = false
      })
    },
    async ajaxFindCountry(query) {
      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}/search?q=${query}`)

      console.log(data)
      return data.resources
    },
    clearAll() {
      this.selectedCountries = []
    },
  },
  mounted() { },
}
</script>

<style lang="postcss"></style>
