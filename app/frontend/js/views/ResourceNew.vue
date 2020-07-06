<template>
  <div v-if="resource">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          Create new {{resourceNameSingular | toLowerCase}}
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
          <router-link
            class="button"
            :to="{
              name: 'index',
              params: {
                resourceName: resourceName,
              },
            }">Cancel</router-link>
          <button class="button" @click="submitResource">Save</button>
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
