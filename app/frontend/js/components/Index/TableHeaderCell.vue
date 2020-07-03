/* eslint-disable import/no-unresolved */
<template>
  <th
    :key="key"
    :class="classes"
  >
    <div class="inline-flex items-center text-gray-700 leading-tight text-sm"
      :class="{'cursor-pointer': sortable}"
      @click="tryAndSort"
    >
      {{field.name}}
      <component :is="sortComponent"
        v-if="sortable"
        class="inline-block h-4 ml-1 fill-current w-3"
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
      const classes = ['text-left', 'uppercase', 'text-sm', 'p-2']

      return classes.join(' ')
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
}
</script>
