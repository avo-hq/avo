<template>
  <a class="block w-full py-2 px-4 font-bold text-gray-600 hover:text-white hover:bg-blue-500"
    :key="action.id"
    href="javascript:void(0);"
    v-text="action.name"
    @click="openModal"
  />
</template>

<script>
import ActionsModal from '@/js/components/Modals/ActionsModal.vue'
// import Api from '@/js/Api'
import Avo from '@/js/Avo'

export default {
  data: () => ({}),
  props: [
    'resourceName',
    'resourceId',
    'action',
  ],
  computed: {},
  methods: {
    openModal() {
      this.$modal.show(ActionsModal, {
        heading: this.action.name,
        text: 'Are you sure you want to run this action?',
        action: this.action,
        resourceName: this.resourceName,
        resourceId: this.resourceId,
      })
    },
  },
  mounted() {},
}
</script>

<style lang="postcss"></style>
