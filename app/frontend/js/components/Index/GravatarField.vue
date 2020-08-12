<template>
  <index-field-wrapper :field="field">
    <div
      :is="element"
      :to="to"
      :title="title"
    >
      <GravatarComponent
        :hashed-email="this.field.value"
        :rounded="this.field.rounded"
        :size="this.field.size"
        :default="this.field.default"
      />
    </div>
  </index-field-wrapper>
</template>

<script>
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'
import GravatarComponent from '@/js/components/GravatarComponent.vue'

export default {
  components: { GravatarComponent },
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
      if (this.field.as_link_to_resource) return 'router-link'

      return 'div'
    },
    to() {
      if (this.field.as_link_to_resource) {
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
      if (this.field.as_link_to_resource) return `View ${this.resourceNameSingular}`

      return null
    },
  },
}
</script>
