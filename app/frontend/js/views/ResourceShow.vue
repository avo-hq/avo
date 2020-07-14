<template>
  <div v-if="resource" class="text-sm">
    <div v-for="(panel, index) in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          {{panel.name}}
        </template>

        <template #tools>
          <div class="flex justify-end" v-if="index === 0">
            <router-link
              class="button"
              :to="{
                name: 'edit',
                params: {
                  resourceName: resourceName,
                  resourceId: resource.id,
                },
              }">Edit</router-link>
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
          ></component>
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
      ></component>
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
  ],
  computed: {
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
