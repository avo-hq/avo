<template>
  <div v-if="resource">
    <view-header>
      <template #heading>
        Edit {{resourceNameSingular}}
      </template>
    </view-header>

    <panel>
      <component
        v-for="field in fields"
        :key="field.id"
        :is="`edit-${field.component}`"
        :field="field"
      ></component>
    </panel>

    <view-footer>
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
    </view-footer>

  </div>
</template>

<script>

export default {
  data: () => ({
    resource: null,
    form: {}
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
      if (!this.resource) {
        return []
      }
      return this.resource.fields.filter(field => field.can_be_updated)
    },
  },
  methods: {
    async getResourceFields() {
      const {data} = await axios.get(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}/fields`)

      this.resource = data.resource
    },
    async updateForm(params) {
      const key = params[0]
      const value = params[1]

      this.form[key] = value
    },
    async updateResource() {
      console.log('updateResource')
      console.log('this.form->', this.form)

      const resource = {}

      this.resource.fields.filter(field => {
        return field.can_be_updated
      }).forEach((field) => {
        console.log('field->', field)
        console.log('field.getValue->', field.getValue())

        resource[field.id] = field.getValue()
      })
      console.log(resource)
      const {data} = await axios.put(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}`, {resource})
      console.log(data)
      // console.log()
    }
  },
  async mounted() {
    await this.getResourceFields()
  },
}
</script>
