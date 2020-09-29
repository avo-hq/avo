/* eslint-disable import/no-unresolved */
<template>
  <th
    :key="key"
    :class="classes"
  >
    <div class="flex items-center text-gray-700 leading-tight text-xs font-semibold"
      :class="{'cursor-pointer': sortable}"
      @click="tryAndSort"
    >
      {{field.name}}
      <component :is="sortComponent"
        v-if="sortable"
        class="inline-block fill-current text-gray-500 relative leading-none min-w-4 min-h-full ml-1 h-4"
      />
    </div>
  </th>
</template>

<script>
export default {
  data: () => ({}),
  props: [
    'resourceName',
    'field',
    'sortBy',
    'sortDirection',
  ],
  computed: {
    classes() {
      const classes = ['text-left', 'uppercase', 'px-3', 'py-2']

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
            return 'sort-ascending-icon'
          case 'desc':
            return 'sort-descending-icon'
          default:
            return 'selector-icon'
        }
      }

      return 'selector-icon'
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
