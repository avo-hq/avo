<template>
  <div class="w-full h-full flex flex-col justify-between">
    <div class="p-4 my-4 text-lg tracking-wide font-bold text-center text-gray-700" v-if="heading">
      {{ heading }}
    </div>
    <div v-if="hasFields">
      <component
        v-for="(field, index) in fields"
        :key="uniqueKey(field, index)"
        :index="index"
        :is="`edit-${field.component}`"
        :field="field"
        :errors="errors"
        :resource-name="resourceName"
        :resource-id="resourceId"
        :field-id="field.id"
        :via-resource-name="viaResourceName"
        :via-resource-id="viaResourceId"
        :field-component="field.component"
        displayed-in="modal"
      />
    </div>
    <div class="flex-1 flex items-center justify-center px-8 text-lg" v-else>
      {{ text }}
    </div>
    <div class="flex justify-end items-baseline space-x-4 p-4 bg-gray-200">
      <a-button
        size="sm"
        @click="$emit('close')"
      >
        Cancel
      </a-button>
      <a-button
        ref="confirm-button"
        color="green"
        size="sm"
        @click="handle"
      >
        Run
      </a-button>
    </div>
  </div>
</template>

<script>
import Api from '@/js/Api'
import Avo from '@/js/Avo'
import HasForms from '@/js/mixins/has-forms'
import HasUniqueKey from '@/js/mixins/has-unique-key'

export default {
  mixins: [HasUniqueKey, HasForms],
  props: [
    'resourceName',
    'resourceId',
    'viaResourceName',
    'viaResourceId',
    'heading',
    'text',
    'action',
  ],
  data: () => ({}),
  computed: {
    hasFields() {
      return this.fields.length > 0
    },
    fields() {
      return this.action.fields
    },
    submitUrl() {
      return `${Avo.rootPath}/avo-api/${this.resourceName}/actions`
    },
  },
  methods: {
    async handle() {
      this.isLoading = true
      this.errors = {}
      // console.log('this.buildFormData()->', this.buildFormData())

      // const data  = await Api({
      //   method: 'POST',
      //   url: this.submitUrl,
      //   data: this.buildFormData({
      //     resource_name: this.resourceName,
      //     resource_id: this.resourceId,
      //     action_id: this.action.id,
      //   }),
      //   headers: {
      //     'Content-Type': 'multipart/form-data',
      //   },
      // })
      // console.log('data->', data)


      try {
        const { data } = await Api({
          method: 'post',
          url: this.submitUrl,
          data: this.buildFormData({
            /* eslint-disable camelcase */
            resource_name: this.resourceName,
            resource_id: this.resourceId,
            action_id: this.action.id,
            action_class: this.action.action_class,
            /* eslint-enable camelcase */
          }, 'fields'),
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })
        console.log('data->', data)

        // const { success } = data
        // const { resource } = data

        // this.resource = resource

        // if (success) {
        //   this.$router.push(this.afterSuccessPath)
        // }
      } catch (error) {
        const { response } = error

        if (response) {
          this.errors = response.data.errors
        } else {
          throw error
        }
      }

      this.isLoading = false
    },
  },
  mounted() {
    this.$refs['confirm-button'].focus()
  },
}
</script>

<style lang="postcss"></style>
