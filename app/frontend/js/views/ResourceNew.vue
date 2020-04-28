<template>
  <div v-if="resource">
    <view-header>
      <template #heading>
        Create new {{resourceNameSingular}}
      </template>
    </view-header>
    <panel>
      <component
        v-for="field in fields"
        :key="field.id"
        :is="`edit-${field.component}`"
        :field="field"
        @update="updateForm"
      ></component>
    </panel>

    <view-footer>
      <router-link
        class="button"
        :to="{
          name: 'index',
          params: {
            resourceName: resourceName,
          },
        }">cancel</router-link>
      <button class="button" @click="createResource">Save</button>
    </view-footer>

  </div>
</template>

<script>
import { Api } from '@/js/Avo'

export default {
  data: () => ({
    resource: {},
    form: {},
  }),
  props: [
    'resourceName',
    'resourceId',
  ],
  computed: {
    resourceNameSingular() {
      return this.resource.resource_name_singular
    },
    fields() {
      if (!this.resource || !this.resource.fields || this.resource.fields.length === 0) {
        return []
      }

      return this.resource.fields.filter((field) => field.can_be_updated)
    },
  },
  methods: {
    async getResourceFields() {
      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}/fields`)

      this.resource = data.resource
    },
    async updateForm(params) {
      const key = params[0]
      const value = params[1]

      this.form[key] = value
    },
    async createResource() {
      const { data } = await Api.post(`/avocado/avocado-api/${this.resourceName}`, this.buildFormData())

      console.log(data)
    },
    buildFormData() {
      const form = new FormData()

      this.resource.fields.filter((field) => field.can_be_updated).forEach((field) => form.append(`resource[${field.id}]`, String(field.getValue())))

      return form
    },
  },
  async mounted() {
    await this.getResourceFields()
  },
}
</script>
