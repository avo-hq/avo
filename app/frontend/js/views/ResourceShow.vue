<template>
  <div v-if="resource">
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
              }">edit</router-link>
          </div>
        </template>

        <template #content>
          <loading-overlay v-if="isLoading" />

          <component
            v-for="(field, index) in fieldsForPanel(panel)"
            :key="field.id"
            :is="`show-${field.component}`"
            :field="field"
            :index="index"
            :resource-name="resourceName"
            :resource-id="resourceId"
            :field-id="field.id"
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
      ></component>
        <!-- :via-resource-name="resourceName"
        :via-resource-id="resourceId" -->
    </div>
  </div>
</template>

<script>
import LoadsResource from '@/js/mixins/loads-resource'

export default {
  name: 'ResourceShow',
  mixins: [LoadsResource],
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
      return this.fields.filter((field) => field.has_many_relationship)
    },
  },
  methods: {
    fieldsForPanel(panel) {
      return this.fields.filter((field) => field.panel_name === panel.name)
    },
  },
}
</script>
