<template>
  <div v-if="resource">
    <view-header>
      <template #heading>
        Create new {{resourceNameSingular}}
      </template>
    </view-header>
    <panel>
      <component
        v-for="field in resource.fields"
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
      <button class="button" @click="updateResource">Save</button>
    </view-footer>

  </div>
</template>

<script>
export default {
  data: () => ({
    resource: {},
    form: {}
  }),
  props: [
    'resourceName',
    'resourceId',
  ],
  computed: {
    resourceNameSingular() {
      return this.resource.resource_name_singular
    }
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
      // const {data} = await axios.put(`/avocado/avocado-api/${this.resourceName}/${this.resourceId}`, {resource: this.form})
      console.log(data)

      // this.resource.fields.forEach((field) => {
      //   console.log('field->', field)
      //   console.log('field.getData->', field.getData())
      // })
      // console.log()
    }
  },
  async mounted() {
    await this.getResourceFields()
  },
}
</script>
