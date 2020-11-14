<template>
  <div class="relative z-30" v-if="actions.length > 0">
    <a-button @click="open = !open"
      color="blue"
      :disabled="isDisabled"
      class="js-actions-toggle-button"
    >
      <arrow-left-icon class="h-4 mr-1 transform -rotate-90"/> {{ $t('avo.actions') }}
    </a-button>
    <div v-on-clickaway="closePanel"
      class="js-actions-panel absolute block inset-auto right-0 top-full bg-white min-w-300px mt-2 py-4 z-20 shadow-context rounded-xl overflow-hidden"
      v-if="open"
    >
      <template v-for="(action, index) in actions">
        <a class="block w-full py-2 px-4 font-bold text-gray-700 hover:text-white hover:bg-blue-500"
          :key="action.id"
          :index="index"
          href="javascript:void(0);"
          v-text="action.name"
          @click="openModal(action)"
        />
      </template>
    </div>
  </div>
</template>

<script>
import { mixin as clickaway } from 'vue-clickaway'
import ActionsModal from '@/js/components/Modals/ActionsModal.vue'

export default {
  mixins: [clickaway],
  data: () => ({
    open: false,
  }),
  props: [
    'resourceName',
    'resourceIds',
    'actions',
  ],
  computed: {
    isDisabled() {
      return !this.resourceIds || this.resourceIds.length === 0
    },
  },
  methods: {
    closePanel() {
      this.open = false
    },
    openModal(action) {
      this.$modal.show(ActionsModal, {
        action,
        heading: action.name,
        resourceName: this.resourceName,
        resourceIds: this.resourceIds,
        noConfirmation: action.no_confirmation,
      })
    },
  },
}
</script>
