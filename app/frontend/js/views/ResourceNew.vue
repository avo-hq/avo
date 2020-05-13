<template>
  <div v-if="resource">
    <div v-for="(panel, index) in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          Create new {{resourceNameSingular}}
        </template>

        <template #content>
          <component
            v-for="field in fields"
            :key="field.id"
            :is="`edit-${field.component}`"
            :field="field"
            @update="updateForm"
          ></component>
        </template>

        <template #footer>
          <router-link
            class="button"
            :to="{
              name: 'index',
              params: {
                resourceName: resourceName,
              },
            }">cancel</router-link>
          <button class="button" @click="createResource">Save</button>
        </template>
      </panel>
    </div>
  </div>
</template>

<script>
import Api from '@/js/Api'
import HasForms from '@/js/mixins/has-forms'

export default {
  mixins: [HasForms],
  data: () => ({
    resource: {},
    form: {},
  }),
  props: [
    'resourceName',
    'resourceId',
  ],
  computed: {},
  methods: {
    async getResource() {
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
  },
  async mounted() {
    await this.getResource()
  },
}
</script>
