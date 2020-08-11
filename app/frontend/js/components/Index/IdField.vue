<template>
  <index-field-wrapper :field="field" class="w-12">
    <div v-if="field.as_link_to_resource && field.value">
      <router-link
        :to="{
          name: 'show',
          params: {
            resourceName: resourcePath,
            resourceId: resource.id,
          },
          query:{
            viaResourceName: viaResourceName,
            viaResourceId: viaResourceId,
          }
        }"
        :title="`View ${this.resourceNameSingular}`"
        data-control="view"
      >
        {{ field.value }}
      </router-link>
    </div>
    <div v-else-if="!field.as_link_to_resource && field.value" v-text="field.value"></div>
    <empty-dash v-else />
  </index-field-wrapper>
</template>

<script>
import DealsWithHasManyRelations from '@/js/mixins/deals-with-has-many-relations'
import DealsWithResourceLabels from '@/js/mixins/deals-with-resource-labels'

export default {
  mixins: [DealsWithHasManyRelations, DealsWithResourceLabels],

  props: [
    'resource',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'field',
  ],
}
</script>
