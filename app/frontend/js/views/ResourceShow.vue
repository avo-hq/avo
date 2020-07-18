<template>
  <div v-if="resource">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          {{panel.name}}
        </template>

        <template #tools>
          <div class="flex justify-end space-x-2">
            <a-button :to="cancelActionParams"><arrow-left-icon class="h-4 mr-1"/> Back</a-button>
            <a-button
              color="indigo"
              :to="{
                name: 'edit',
                params: {
                  resourceName: resourceName,
                  resourceId: resource.id,
                },
              }"><edit-icon class="h-4 mr-1" /> Edit</a-button>
          </div>
        </template>

        <template #content>
          <loading-overlay v-if="isLoading" />

          <component
            v-for="(field, index) in fieldsForPanel(panel)"
            :key="uniqueKey(field)"
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
import HasUniqueKey from '@/js/mixins/has-unique-key'
import LoadsResource from '@/js/mixins/loads-resource'

export default {
  name: 'ResourceShow',
  mixins: [LoadsResource, HasUniqueKey],
  data: () => ({
    resource: null,
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
  },
  methods: {
    fieldsForPanel(panel) {
      return this.fields.filter((field) => field.panel_name === panel.name)
    },
  },
}
</script>
