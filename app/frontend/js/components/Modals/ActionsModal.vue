<template>
  <div class="w-full h-full flex flex-col justify-between" v-if="!noConfirmation">
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
        :field-id="field.id"
        :via-resource-name="viaResourceName"
        :via-resource-id="viaResourceId"
        :field-component="field.component"
        displayed-in="modal"
      />
    </div>
    <div class="flex-1 flex items-center justify-center px-8 text-lg mt-8 mb-12" v-else>
      {{ action.message }}
    </div>
    <div class="flex justify-end items-baseline space-x-4 p-4 bg-gray-200">
      <a-button
        size="sm"
        @click="$emit('close')"
        v-text="action.cancel_text"
      />
      <a-button
        ref="confirm-button"
        :color="buttonColor"
        size="sm"
        @click="handle"
        v-text="action.confirm_text"
      />
    </div>
  </div>
</template>

<script>
import Api from '@/js/Api'
import Avo from '@/js/Avo'
import Bus from '@/js/Bus'
import HasForms from '@/js/mixins/has-forms'
import HasUniqueKey from '@/js/mixins/has-unique-key'

export default {
  mixins: [HasUniqueKey, HasForms],
  props: [
    'resourceName',
    'resourceIds',
    'viaResourceName',
    'viaResourceId',
    'heading',
    'action',
    'noConfirmation',
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
    buttonColor() {
      switch (this.action.theme) {
        default:
        case 'success':
          return 'green'
        case 'error':
          return 'red'
        case 'warning':
          return 'orange'
      }
    },
  },
  methods: {
    async handle() {
      this.isLoading = true
      this.errors = {}

      try {
        const { data } = await Api({
          method: 'post',
          url: this.submitUrl,
          data: this.buildFormData({
            /* eslint-disable camelcase */
            resource_name: this.resourceName,
            resource_ids: this.resourceIds,
            action_id: this.action.id,
            action_class: this.action.action_class,
            /* eslint-enable camelcase */
          }, 'fields'),
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })

        const {
          resource,
          success,
          response,
        } = data

        const {
          message,
          message_type: messageType,
          type,
          path,
          filename,
        } = response

        this.resource = resource

        if (success) {
          this.$emit('close')

          if (['success', 'error'].includes(messageType)) {
            Avo.alert(message, messageType)
          }

          if (type === 'redirect') {
            Avo.redirect(path)
          }

          if (type === 'http_redirect') {
            window.location = path
          }

          if (type === 'reload') {
            Avo.reload()
          }

          if (type === 'reload_resources') {
            Bus.$emit('reload-resources')
          }

          if (type === 'open_in_new_tab') {
            window.open(path)
          }

          if (type === 'download') {
            window.fetch(path, {
              headers: {
                'Content-Disposition': 'form-data; name="fieldName"; filename="filename.jpg',
              },
            }).then((res) => res.blob())
              .then((blob) => {
                const a = document.createElement('a')
                a.href = URL.createObjectURL(blob)
                a.setAttribute('download', filename)
                a.click()
              })
          }
        }
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
    if (this.noConfirmation) {
      this.handle()
    } else {
      this.$refs['confirm-button'].focus()
    }
  },
}
</script>

<style lang="postcss"></style>
