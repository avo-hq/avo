/* eslint-disable import/no-unresolved */
<template>
  <th
    :key="key"
    :class="classes"
  >
    <div class="inline-block"
      :class="{'cursor-pointer': sortable}"
      @click="tryAndSort"
    >
      {{field.name}}
      <component :is="sortComponent"
        v-if="sortable"
        class="inline-block h-4"
       />
    </div>
  </th>
</template>

<script>
/* eslint-disable import/no-unresolved */
import Sort from '@/svgs/sort.svg?inline'
import SortDown from '@/svgs/sort-down.svg?inline'
import SortUp from '@/svgs/sort-up.svg?inline'
/* eslint-enable import/no-unresolved */

export default {
  components: { Sort, SortUp, SortDown },
  data: () => ({}),
  props: [
    'resourceName',
    'field',
    'sortBy',
    'sortDirection',
  ],
  computed: {
    classes() {
      let classes = 'text-left uppercase text-sm py-2'

      if (this.field.id === 'id') classes += ' w-12'

      return classes
    },
    key() {
      return `header-${this.resourceName}-${this.field.id}`
    },
    sortable() {
      return this.field.sortable
    },
    sortComponent() {
      if (this.sortBy === this.field.id) {
        switch (this.sortDirection) {
          case 'asc':
            return 'SortUp'
          case 'desc':
            return 'SortDown'
          default:
            return 'Sort'
        }
      }

      return 'Sort'
    },
  },
  methods: {
    tryAndSort() {
      if (!this.sortable) return

      this.$emit('sort')
    },
  },
  mounted() {},
}
</script>

<style lang="postcss"></style>
