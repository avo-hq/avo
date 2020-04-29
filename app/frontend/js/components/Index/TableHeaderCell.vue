<template>
  <th
    :key="key"
    class="text-left uppercase text-sm py-2"
  >
    <div class="inline-block"
      :class="{'cursor-pointer': sortable}"
      @click="$emit('sort')"
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
import Sort from '@/svgs/sort.svg?inline'
import SortUp from '@/svgs/sort-up.svg?inline'
import SortDown from '@/svgs/sort-down.svg?inline'

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
    key() {
      return `header-${this.ressourceName}-${this.field.id}`
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
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
