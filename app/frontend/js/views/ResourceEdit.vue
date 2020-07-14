<template>
  <div v-if="resource" class="text-sm">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
            Edit {{resourceNameSingular}}
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
              :resource-name="resourceName"
              :resource-id="resourceId"
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
            :to="cancelActionParams">Cancel</router-link>
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
    resource: null,
    form: {},
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
        name: 'show',
        params: {
          resourceName: this.resourceName,
          resourceId: this.resource.id,
        },
      }

      if (this.viaResourceName) {
        action.params.resourceName = this.viaResourceName
        action.params.resourceId = this.viaResourceId
      }

      return action
    },
  },
}
</script>
