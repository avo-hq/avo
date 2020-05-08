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
          <component
            v-for="field in fieldsForPanel(panel)"
            :key="field.id"
            :is="`show-${field.component}`"
            :field="field"
          ></component>
        </template>
      </panel>
    </div>
  </div>
</template>

<script>
import Api from '@/js/Api'

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
    fieldsForPanel(panel) {
      return this.fields.filter((field) => field.panel_name === panel.name)
    },
  },
  async mounted() {
    await this.getResource()
  },
}
</script>
