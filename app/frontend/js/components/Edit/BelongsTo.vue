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
      <select :name="field.id"
        ref="field-input"
        :id="field.id"
        :class="inputClasses"
        class="select-input w-full"
        v-model="selectedValue"
        :disabled="disabled"
      >
        <option value="" v-text="placeholder"/>
        <option v-for="option in options"
          :key="option.value"
          :value="option.value"
          v-text="option.label"
        />
      </select>
    </div>
    <template #extra>
      <div v-if="searchable">
        <a-button color="indigo"
          @click="removeSelection"
        >Remove selection</a-button>
      </div>
    </template>
  </edit-field-wrapper>
</template>

<script>
import Bus from '@/js/Bus'
import FormField from '@/js/mixins/form-field'
import HasInputAppearance from '@/js/mixins/has-input-appearance'
import isUndefined from 'lodash/isUndefined'

export default {
  mixins: [FormField, HasInputAppearance],
  data: () => ({
    options: [],
    value: {},
    selectedValue: '',
    isLoading: false,
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'field',
  ],
  computed: {
    disabled() {
      return !isUndefined(this.viaResourceName)
    },
    searchable() {
      return this.field.searchable
    },
    placeholder() {
      if (this.field.placeholder) return this.field.placeholder

      return `Choose ${this.field.id}`
    },
  },
  methods: {
    select(resource) {
      this.selectedValue = resource.id
    },
    getValue() {
      return this.selectedValue
    },
    getId() {
      return this.field.database_id
    },
    removeSelection() {
      this.selectedValue = {}
      Bus.$emit(`clearSearchSelection${this.field.id}`)
    },
  },
  mounted() {
    this.options = this.field.options
    if (this.field.database_value) this.selectedValue = this.field.database_value
  },
}
</script>
