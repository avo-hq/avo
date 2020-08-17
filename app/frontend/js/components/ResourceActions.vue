<template>
  <div class="relative z-30" v-if="hasActions">
    <a-button @click="togglePanel" color="blue">
      <arrow-left-icon class="h-4 mr-1 transform -rotate-90"/> Actions
    </a-button>
    <div v-on-clickaway="onClickAway"
      class="absolute block inset-auto right-0 top-full bg-white min-w-300px mt-2 py-4 z-20 shadow-row rounded-xl overflow-hidden"
      v-if="open"
    >
      <template v-for="(action, index) in actions">
        <resource-action
          :key="index"
          :index="index"
          :resource-name="resourceName"
          :resource-id="resourceId"
          :action="action"
        />
      </template>
    </div>
  </div>
</template>

<script>
import { mixin as clickaway } from 'vue-clickaway'

export default {
  mixins: [clickaway],
  data: () => ({
    open: false,
  }),
  props: [
    'resourceName',
    'resourceId',
    'actions',
  ],
  computed: {
    hasActions() {
      return this.actions.length > 0
    },
  },
  methods: {
    togglePanel() {
      console.log('togglePanel')
      this.open = !this.open
    },
    onClickAway() {
      this.open = false
    },
  },
}
</script>
