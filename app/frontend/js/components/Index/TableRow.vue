<template>
  <tr v-if="resource" class="border-t hover:bg-gray-100">
    <td>
      <div class="flex justify-center h-full">
        <input type="checkbox" />
      </div>
    </td>
    <component
      v-for="field in fields"
      :key="field.id"
      :is="`index-${field.component}`"
      :field="field"
    ></component>

    <td class="text-right p-2">
      <div class="flex items-center justify-end flex-grow-0 space-x-1 h-full w-full">
        <router-link
          :to="{
            name: 'show',
            params: {
              resourceName: resourceName,
              resourceId: resource.id
            }
          }"
          v-tooltip="`View ${this.resourceNameSingular}`"
          ><ViewIcon class="text-gray-400 h-6 fill-current hover:text-gray-500"
        /></router-link>
        <router-link
          :to="{
            name: 'edit',
            params: {
              resourceName: resourceName,
              resourceId: resource.id
            }
          }"
          v-tooltip="`Edit ${this.resourceNameSingular}`"
          ><EditIcon class="text-gray-400 h-6 hover:text-gray-500"
        /></router-link>
        <a href="javascript:void(0);" @click="openDeleteModal"
          v-tooltip="`Delete ${this.resourceNameSingular}`"
          ><DeleteIcon class="text-gray-400 h-6 hover:text-gray-500"
        /></a>
      </div>
    </td>
  </tr>
</template>

<script>
import { Api } from '@/js/Avo'
import pluralize from 'pluralize'
/* eslint-disable import/no-unresolved */
import DeleteIcon from '@/svgs/trash.svg?inline'
import EditIcon from '@/svgs/edit.svg?inline'
import Modal from '@/js/components/Modal'
import ViewIcon from '@/svgs/eye.svg?inline'
/* eslint-enable import/no-unresolved */
import ExtractsFields from '@/js/mixins/extracts-fields'

export default {
  components: {
    ViewIcon, EditIcon, DeleteIcon,
  },
  data: () => ({}),
  mixins: [ExtractsFields],
  props: [
    'resource',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
  ],
  computed: {
    resourceNameSingular() {
      return pluralize(this.resourceName, 1)
    },
    resourceFields() {
      if (this.resource
        && this.resource.fields
        && this.resource.fields.length > 0) return this.resource.fields

      return []
    },
  },
  methods: {
    async deleteResource() {
      await Api.delete(`/avocado/avocado-api/${this.resourceName}/${this.resource.id}`)
    },
    openDeleteModal() {
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
