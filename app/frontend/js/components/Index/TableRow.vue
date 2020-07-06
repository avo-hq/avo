<template>
  <tr v-if="resource"
    class="border-t hover:bg-gray-100"
    :resource-name="resourceName"
    :resource-id="resource.id"
  >
    <td class="w-10">
      <div class="flex justify-center h-full">
        <input type="checkbox" class="mx-3" />
      </div>
    </td>
    <component
      v-for="field in fields"
      :key="uniqueKey(field)"
      :is="`index-${field.component}`"
      :field="field"
      :field-id="field.id"
      :field-component="field.component"
    ></component>

    <td class="text-right p-2">
      <div class="flex items-center justify-end flex-grow-0 space-x-2 pr-2 h-full w-full">
        <router-link
          :to="{
            name: 'show',
            params: {
              resourceName: resourcePath,
              resourceId: resource.id
            }
          }"
          v-tooltip="`View ${this.resourceNameSingular}`"
          data-control="view"
          ><ViewIcon class="text-gray-400 h-6 fill-current hover:text-gray-500"
        /></router-link>
        <router-link
          :to="editActionParams"
          v-tooltip="`Edit ${this.resourceNameSingular}`"
          data-control="edit"
          ><EditIcon class="text-gray-400 h-6 hover:text-gray-500"
        /></router-link>
        <a href="javascript:void(0);"
          @click="openDetachModal"
          v-tooltip="`Detach ${this.resourceNameSingular}`"
          data-control="detach"
          v-if="relationship === 'has_and_belongs_to_many'"
          ><DeleteIcon class="text-gray-400 h-6 hover:text-gray-500"
        /></a>
        <a href="javascript:void(0);"
          @click="openDeleteModal"
          v-tooltip="`Delete ${this.resourceNameSingular}`"
          data-control="delete"
          v-else
          ><DeleteIcon class="text-gray-400 h-6 hover:text-gray-500"
        /></a>
      </div>
    </td>
  </tr>
</template>

<script>
import { Api } from '@/js/Avo'
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
/* eslint-disable import/no-unresolved */
import DeleteIcon from '@/svgs/trash.svg?inline'
import EditIcon from '@/svgs/edit.svg?inline'
import Modal from '@/js/components/Modal'
import ViewIcon from '@/svgs/eye.svg?inline'
/* eslint-enable import/no-unresolved */
import ExtractsFields from '@/js/mixins/extracts-fields'
import HasUniqueKey from '@/js/mixins/has-unique-key'
import isUndefined from 'lodash/isUndefined'

export default {
  components: {
    ViewIcon, EditIcon, DeleteIcon,
  },
  data: () => ({}),
  mixins: [DealsWithResourceLabels, ExtractsFields, DealsWithHasManyRelations, HasUniqueKey],
  props: [
    'resource',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'field',
  ],
  computed: {
    afterSuccessPath() {
      if (!isUndefined(this.viaResourceName)) return `/resources/${this.viaResourceName}/${this.viaResourceId}`

      return `/resources/${this.resourceName}`
    },
    editActionParams() {
      const action = {
        name: 'edit',
        params: {
          resourceName: this.resourcePath,
          resourceId: this.resource.id,
        },
        query: {},
      }

      if (this.viaResourceName) {
        action.query.viaResourceName = this.viaResourceName
        action.query.viaResourceId = this.viaResourceId
      }

      return action
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
      await Api.delete(`/avocado/avocado-api/${this.resourcePath}/${this.resource.id}`)

      this.$modal.hideAll()

      this.$emit('resource-deleted')
    },
    async detachResource() {
      await Api.post(`/avocado/avocado-api/${this.viaResourceName}/${this.viaResourceId}/detach/${this.resourcePath}/${this.resource.id}`)

      this.$modal.hideAll()

      this.$emit('resource-deleted')
    },
    openDeleteModal() {
      this.$modal.show(Modal, {
        heading: `Delete ${this.resourceNameSingular}`,
        text: 'Are you sure?',
        confirmAction: this.deleteResource,
      })
    },
    openDetachModal() {
      this.$modal.show(Modal, {
        text: `Are you sure you want to detach this ${this.resourceNameSingular.toLowerCase()}?`,
        confirmAction: this.detachResource,
      })
    },
  },
  mounted() { },
}
</script>
