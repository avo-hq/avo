<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div v-if="searchable">
      <resources-search :resource-name="field.id"
        :via-resource-name="resourceName"
        :single="true"
        @select="select"
      />
    </div>
    <div v-else>
      <select name="options" id="options" v-model="selectedValue">
        <option v-for="option in options"
          :key="option.value"
          :value="option.value"
          v-text="option.label"
          ></option>
      </select>
    </div>
  </edit-field-wrapper>
</template>

<script>
import '~/vue-multiselect/dist/vue-multiselect.min.css'
import FormField from '@/js/mixins/form-field'
import Multiselect from 'vue-multiselect'

export default {
  components: { Multiselect },
  mixins: [FormField],
  data: () => ({
    options: [],
    value: {},
    selectedValue: null,
    isLoading: false,
  }),
  props: ['resourceName', 'field'],
  computed: {
    searchable() {
      return this.field.searchable
    },
  },
  methods: {
    select(resource) {
      this.selectedValue = resource.id
    },
    getValue() {
      return this.selectedValue
    },
  },
  mounted() {
    this.options = this.field.options
    this.selectedValue = this.field.select_value
  },
}
</script>

<style lang="postcss"></style>
