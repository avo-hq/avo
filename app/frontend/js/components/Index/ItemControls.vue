<template>
  <div class="space-x-2">
    <router-link
      :to="{
        name: 'show',
        params: {
          resourceName: resourcePath,
          resourceId: resource.id,
        },
        query:{
          viaResourceName: viaResourceName,
          viaResourceId: viaResourceId,
        }
      }"
      :title="viewTooltipLabel"
      data-control="view"
      v-if="canView"
    >
      <eye-icon :class="iconClasses"/>
    </router-link>
    <router-link
      :to="{
        name: 'edit',
        params: {
          resourceName: resourcePath,
          resourceId: resource.id,
        },
        query: {
          viaResourceName: viaResourceName,
          viaResourceId: viaResourceId,
        },
      }"
      :title="editTooltipLabel"
      data-control="edit"
      v-if="canEdit"
    >
      <edit-icon :class="iconClasses"/>
    </router-link>
    <a href="javascript:void(0);"
      @click="openDetachModal"
      :title="detachTooltipLabel"
      data-control="detach"
      v-if="canAttachResources"
    >
      <switch-horizontal-icon :class="iconClasses"/>
    </a>
    <a href="javascript:void(0);"
      @click="openDeleteModal"
      :title="deleteTooltipLabel"
      data-control="delete"
      v-else-if="canDelete"
    >
      <trash-icon :class="iconClasses"/>
    </a>
  </div>
</template>

<script>
import Avo, { Api } from '@/js/Avo'
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import Modal from '@/js/components/Modal.vue'
import isUndefined from 'lodash/isUndefined'
import upperFirst from 'lodash/upperFirst'

export default {
  mixins: [DealsWithHasManyRelations, DealsWithResourceLabels],
  data: () => ({
    iconClasses: 'text-gray-500 h-6 hover:text-gray-600',
  }),
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
    canEdit() {
      return this.resource.authorization.edit
    },
    canView() {
      return this.resource.authorization.show
    },
    canDelete() {
      return this.resource.authorization.destroy
    },
    viewTooltipLabel() {
      return upperFirst(this.$t('avo.view_item', { item: this.resourceNameSingular.toLowerCase() }))
    },
    editTooltipLabel() {
      return upperFirst(this.$t('avo.edit_item', { item: this.resourceNameSingular.toLowerCase() }))
    },
    detachTooltipLabel() {
      return upperFirst(this.$t('avo.detach_item', { item: this.resourceNameSingular.toLowerCase() }))
    },
    deleteTooltipLabel() {
      return upperFirst(this.$t('avo.delete_item', { item: this.resourceNameSingular.toLowerCase() }))
    },
  },
  methods: {
    async deleteResource() {
      await Api.delete(`${Avo.rootPath}/avo-api/${this.resourcePath}/${this.resource.id}`)

      this.$modal.hideAll()

      this.$emit('resource-deleted')
    },
    async detachResource() {
      const resourcePath = this.hasManyThrough ? this.field.id : this.resourcePath
      await Api.post(`${Avo.rootPath}/avo-api/${this.viaResourceName}/${this.viaResourceId}/detach/${resourcePath}/${this.resource.id}`)

      this.$modal.hideAll()

      this.$emit('resource-deleted')
    },
    openDeleteModal() {
      this.$modal.show(Modal, {
        heading: upperFirst(this.$t('avo.delete_item', { item: this.resourceNameSingular })),
        text: upperFirst(this.$t('avo.are_you_sure')),
        confirmAction: this.deleteResource,
      })
    },
    openDetachModal() {
      this.$modal.show(Modal, {
        heading: upperFirst(this.$t('avo.detach_item', { item: this.resourceNameSingular.toLowerCase() })),
        text: upperFirst(this.$t('avo.are_you_sure')),
        confirmAction: this.detachResource,
      })
    },
  },
  mounted() {},
}
</script>
