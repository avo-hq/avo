<template>
  <div v-if="resource">
    <div v-for="(panel, index) in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
            Edit {{resourceNameSingular}}
        </template>

        <template #content>
          <component
            v-for="field in fields"
            :key="field.id"
            :is="`edit-${field.component}`"
            :field="field"
          ></component>
        </template>

        <template #footer>
          <router-link
            class="button"
            :to="{
              name: 'show',
              params: {
                resourceName: resourceName,
                resourceId: resource.id,
              },
            }">cancel</router-link>
          <button class="button" @click="updateResource">Save</button>
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
    resource: null,
    form: {},
  }),
  props: [
    'resourceName',
    'resourceId',
  ],
  computed: {},
  methods: {
    async getResourceFields() {
      const { data } = await Api.get(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}`)

      this.resource = data.resource
    },
    async updateForm(params) {
      const key = params[0]
      const value = params[1]

      this.form[key] = value
    },
    async updateResource() {
      console.log('updateResource')

      const { data } = await Api.put(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}`, this.buildFormData())

      console.log(data)
    },
  },
  async mounted() {
    await this.getResourceFields()
  },
}
</script>
