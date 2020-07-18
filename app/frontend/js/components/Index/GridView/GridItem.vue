<template>
  <div class="relative bg-white rounded-xl shadow-xl flex flex-col">
    <router-link class="relative w-full pb-3/4 rounded-t-xl overflow-hidden"
      :to="{
        name: 'show',
        params: {
          resourceId: this.resource.id,
          resourceName: this.resourceName,
        },
        query:{
          viaResourceName: viaResourceName,
          viaResourceId: viaResourceId,
        }
      }"
    >
      <img :src="preview"
        :alt="title"
        class="absolute h-full w-full object-cover"
        v-if="preview"
      />
      <div class="absolute bg-gray-100 w-full h-full" v-else>
        <avocado-icon class="relative transform -translate-x-1/2 -translate-y-1/2 h-20 text-gray-400 inset-auto top-1/2 left-1/2" />
      </div>
    </router-link>
    <div class="flex flex-col justify-between p-4 flex-1">
      <div class="font-semibold leading-tight mb-2">
        {{title}}
      </div>
      <div class="mb-6">
        {{body}}
      </div>
      <div class="w-full">
        <item-controls
          class="flex flex-row justify-around w-full"
          :resource="resource"
          :resource-name="resourceName"
          :via-resource-name="viaResourceName"
          :via-resource-id="viaResourceId"
          :field="field"
          @resource-deleted="$emit('resource-deleted')"
        />
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: [
    'resource',
    'resourceName',
    'viaResourceName',
    'viaResourceId',
    'field',
  ],
  computed: {
    preview() {
      return this.resource.grid_fields.preview.value
    },
    title() {
      return this.resource.grid_fields.title.value
    },
    body() {
      return this.resource.grid_fields.body.value
    },
  },
}
</script>
