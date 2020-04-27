<template>
  <div v-if="resource">
    <view-header>
      <template #heading>
        {{resource.title}}
      </template>

      <template #tools>
        <div class="flex justify-end">
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
    </view-header>

    <panel>
      <component
        v-for="field in fields"
        :key="field.id"
        :is="`show-${field.component}`"
        :field="field"
      ></component>
    </panel>
  </div>
</template>

<script>
import { Api } from '@/js/Avo'

export default {
  name: 'ResourceShow',
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
  },
  methods: {
    async getResource() {
      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}`)

      this.resource = data.resource
    },
  },
  async mounted() {
    await this.getResource()
  },
}
</script>
