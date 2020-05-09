<template>
  <tr v-if="resource" class="border-t hover:bg-gray-100">
    <td>
      <div class="flex justify-center h-full">
        <input type="checkbox" />
      </div>
    </td>
    <component
      v-for="field in resource.fields"
      :key="field.id"
      :is="`index-${field.component}`"
      :value="field.value"
    ></component>

    <td class="flex justify-end text-right py-2">
      <router-link
        :to="{
          name: 'show',
          params: {
            resourceName: resourceName,
            resourceId: resource.id
          }
        }"
        ><ViewIcon class="text-gray-400 h-6 mr-2"
      /></router-link>
      <router-link
        :to="{
          name: 'edit',
          params: {
            resourceName: resourceName,
            resourceId: resource.id
          }
        }"
        ><EditIcon class="text-gray-400 h-6 mr-2"
      /></router-link>
      <a href="javascript:void(0);" @click="openDeleteModal"
        ><DeleteIcon class="text-gray-400 h-6 mr-2"
      /></a>
    </td>
  </tr>
</template>

<script>
import { Api } from '@/js/Avo'
/* eslint-disable import/no-unresolved */
import DeleteIcon from '@/svgs/trash.svg?inline'
import EditIcon from '@/svgs/edit.svg?inline'
import Modal from '@/js/components/Modal'
import ViewIcon from '@/svgs/eye.svg?inline'
/* eslint-enable import/no-unresolved */

export default {
  components: {
    ViewIcon, EditIcon, DeleteIcon,
  },
  data: () => ({}),
  props: [
    'resource',
    'resourceName',
  ],
  methods: {
    async deleteResource() {
      await Api.delete(`/avocado/avocado-api/${this.resourceName}/${this.resource.id}`)
    },
    openDeleteModal() {
      console.log('openDeleteModal', this.$modal)
      // @todo: fix modal in turbolinks
      this.$modal.show(Modal, {
        text: 'Are you sure?',
        confirmAction: () => this.deleteResource(),
      })
    },
  },
  mounted() { },
}
</script>

<style lang="postcss"></style>
