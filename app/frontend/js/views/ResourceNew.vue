<template>
  <div v-if="resource" class="text-sm">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          Create new {{resourceNameSingular | toLowerCase}}
        </template>

        <template #tools>
          <div class="flex justify-end space-x-2">
            <a-button :to="{
              name: 'index',
              params: {
                resourceName: resourceName,
              },
            }"><arrow-left-icon class="h-4 mr-1"/> Cancel</a-button>
            <a-button color="green" @click="submitResource"><save-icon class="h-4 mr-1"/> Save</a-button>
          </div>
        </template>

        <template #content>
          <loading-overlay v-if="isLoading" />

          <form @submit.prevent="submitResource">
            <component
              v-for="(field, index) in fields"
              :key="uniqueKey(field)"
              :index="index"
              :is="`edit-${field.component}`"
              :field="field"
              :errors="errors"
              :field-id="field.id"
              :via-resource-name="viaResourceName"
              :via-resource-id="viaResourceId"
              :field-component="field.component"
            ></component>

            <input type="submit" class="hidden">
          </form>
        </template>

        <template #footer>
        </template>
      </panel>
    </div>
  </div>
</template>

<script>
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import HasForms from '@/js/mixins/has-forms'
import HasUniqueKey from '@/js/mixins/has-unique-key'
import LoadsResource from '@/js/mixins/loads-resource'

export default {
  mixins: [HasForms, LoadsResource, DealsWithResourceLabels, HasUniqueKey],
  data: () => ({
    resource: {},
    form: {},
  }),
  props: [
    'resourceName',
    'viaResourceName',
    'viaResourceId',
  ],
}
</script>
