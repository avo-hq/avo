<template>
  <div v-if="resource" :resource-id="resourceId">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          {{panel.name}}
        </template>

        <template #tools>
          <div class="flex justify-end space-x-2">
            <resource-actions :resource-name="resourceName" :resource-ids="[resourceId]" :actions="actions" />
            <a-button :to="cancelActionParams"><arrow-left-icon class="h-4 mr-1"/> Back</a-button>
            <a-button @click="openDeleteModal"
              color="red"
              variant="outlined"
              v-if="canDelete"
            >
              <trash-icon class="text-red-700 h-4 mr-1"/>
              Delete
            </a-button>
            <a-button
              color="indigo"
              :to="{
                name: 'edit',
                params: {
                  resourceName: resourceName,
                  resourceId: resource.id,
                },
              }"
              v-if="canEdit"
            ><edit-icon class="h-4 mr-1" /> Edit</a-button>
          </div>
        </template>

        <template #content>
          <loading-overlay v-if="isLoading" />

          <component
            v-for="(field, index) in fieldsForPanel(panel)"
            :key="uniqueKey(field, index)"
            :is="`show-${field.component}`"
            :field="field"
            :index="index"
            :resource-name="resourceName"
            :resource-id="resourceId"
            :field-id="field.id"
            :field-component="field.component"
          />
        </template>
      </panel>

      <component
        v-for="field in hasManyRelations"
        :key="field.id"
        :is="`show-${field.component}`"
        :field="field"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :field-component="field.component"
      />
    </div>
  </div>
</template>

<script>
import Avo, { Api } from '@/js/Avo'
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import HasUniqueKey from '@/js/mixins/has-unique-key'
import LoadsActions from '@/js/mixins/loads-actions'
import LoadsResource from '@/js/mixins/loads-resource'
import Modal from '@/js/components/Modal.vue'

export default {
  name: 'ResourceShow',
  mixins: [LoadsResource, LoadsActions, HasUniqueKey, DealsWithResourceLabels, DealsWithHasManyRelations],
  data: () => ({
    resource: null,
    actions: [],
  }),
  props: [
    'resourceName',
    'resourceId',
    'viaResourceName',
    'viaResourceId',
  ],
  computed: {
    cancelActionParams() {
      const action = {
        name: 'index',
        params: {
          resourceName: this.resourceName,
        },
      }

      if (this.viaResourceName) {
        action.name = 'show'
        action.params.resourceName = this.viaResourceName
        action.params.resourceId = this.viaResourceId
      }

      return action
    },
    fields() {
      return this.resource.fields
    },
    hasManyRelations() {
      return this.fields.filter((field) => ['has_and_belongs_to_many', 'has_many'].indexOf(field.relationship) > -1)
    },
    canEdit() {
      return this.resource.authorization.update
    },
    canDelete() {
      return this.resource.authorization.destroy
    },
  },
  methods: {
    fieldsForPanel(panel) {
      return this.fields.filter((field) => field.panel_name === panel.name)
    },
    async deleteResource() {
      await Api.delete(`${Avo.rootPath}/avo-api/${this.resourcePath}/${this.resource.id}`)

      this.$modal.hideAll()

      Avo.redirect(`/resources/${this.resourcePath}`)
    },
    openDeleteModal() {
      this.$modal.show(Modal, {
        heading: `Delete ${this.resourceNameSingular}`,
        text: 'Are you sure?',
        confirmAction: this.deleteResource,
      })
    },
  },
}
</script>
