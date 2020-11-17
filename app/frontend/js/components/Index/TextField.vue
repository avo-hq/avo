<template>
  <index-field-wrapper :field="field">
    <div v-if="field.value"
      v-text="field.value"
      :is="element"
      :to="to"
      :title="title"
    />
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import upperFirst from 'lodash/upperFirst'

export default {
  mixins: [DealsWithHasManyRelations, DealsWithResourceLabels],
  props: [
    'resource',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'field',
  ],
  computed: {
    element() {
      if (this.field.linkToResource && this.canView) return 'router-link'

      return 'div'
    },
    to() {
      if (this.field.linkToResource && this.canView) {
        return {
          name: 'show',
          params: {
            resourceName: this.resourcePath,
            resourceId: this.resource.id,
          },
          query: {
            viaResourceName: this.viaResourceName,
            viaResourceId: this.viaResourceId,
          },
        }
      }

      return null
    },
    title() {
      if (this.field.linkToResource && this.canView) upperFirst(this.$t('avo.view_item', { item: this.resourceNameSingular.toLowerCase() }))

      return null
    },
    canView() {
      return this.resource.authorization.show
    },
  },
}
</script>
