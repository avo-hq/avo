<template>
  <div :resource-id="resourceId">
    <div v-for="panel in panels" :key="panel.name">
      <panel>
        <template #heading>
          {{panel.name}}
        </template>

        <template #tools>
          <div class="flex justify-end space-x-2">
            <a-button :to="cancelActionParams"><arrow-left-icon class="h-4 mr-1"/> {{ $t('avo.cancel') | upperFirst() }} </a-button>
            <a-button
              v-if="canUpdate"
              color="green"
              @click="submitResource"
            ><save-icon class="h-4 mr-1"/> {{ $t('avo.save') | upperFirst() }}</a-button>
          </div>
        </template>

        <template #content>
          <loading-overlay v-if="isLoading" />

          <form @submit.prevent="submitResource">
            <component
              v-for="(field, index) in fields"
              :key="uniqueKey(field, index)"
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
            />

            <input type="submit" class="hidden">
          </form>
        </template>

        <template #footer/>
      </panel>
    </div>
  </div>
</template>

<script>
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import HasForms from '@/js/mixins/has-forms'
import HasUniqueKey from '@/js/mixins/has-unique-key'
import LoadsResource from '@/js/mixins/loads-resource'
import hasUpperFirstFilter from '@/js/mixins/has-upper-first-filter'
import upperFirst from 'lodash/upperFirst'

export default {
  mixins: [HasForms, LoadsResource, DealsWithResourceLabels, HasUniqueKey, hasUpperFirstFilter],
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
    panels() {
      if (!this.resource) return [{ name: upperFirst(this.$t('avo.edit_item', { item: this.resourceNameFromURL })) }]

      return this.resource.panels
    },
    cancelActionParams() {
      const action = {
        name: 'show',
        params: {
          resourceName: this.resourceName,
          resourceId: this.resourceId,
        },
      }

      if (this.viaResourceName) {
        action.params.resourceName = this.viaResourceName
        action.params.resourceId = this.viaResourceId
      }

      return action
    },
    canUpdate() {
      if (!this.resource) return false

      return this.resource.authorization.update
    },
  },
}
</script>
