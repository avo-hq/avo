<template>
  <edit-field-wrapper :field="field" :errors="errors" :index="index">
    <div v-if="searchable">
      <resources-search :resource-name="field.id"
        :via-resource-name="resourceName"
        :single="true"
        :search-value="field.model"
        :value="selectedValue"
        @select="select"
        :field-id="field.id"
      />
    </div>
    <div v-else>
      <select name="options"
        id="options"
        class="w-full"
        v-model="selectedValue"
      >
        <option v-for="option in options"
          :key="option.value"
          :value="option.value"
          v-text="option.label"
          ></option>
      </select>
    </div>
    <template #extra>
      <div v-if="searchable">
        <button @click="removeSelection">remove selection</button>
      </div>
    </template>
  </edit-field-wrapper>
</template>

<script>
import Bus from '@/js/Bus'
import FormField from '@/js/mixins/form-field'

export default {
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
      console.log('select parent')
      this.selectedValue = resource.id
    },
    getValue() {
      return this.selectedValue
    },
    getId() {
      return this.field.database_field_name
    },
    removeSelection() {
      console.log('remove selection')
      this.selectedValue = {}
      Bus.$emit(`clearSearchSelection${this.field.id}`)
    },
  },
  mounted() {
    this.options = this.field.options
    this.selectedValue = this.field.select_value
  },
}
</script>
