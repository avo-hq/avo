<template>
  <div v-if="resource">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
          Create new {{resourceNameSingular}}
        </template>

        <template #content>
          <loading-overlay v-if="isLoading" />
          <component
            v-for="(field, index) in fields"
            :key="field.id"
            :index="index"
            :is="`edit-${field.component}`"
            :field="field"
            :errors="errors"
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
            }">Cancel</router-link>
          <button class="button" @click="submitResource">Save</button>
        </template>
      </panel>
    </div>
  </div>
</template>

<script>
import HasForms from '@/js/mixins/has-forms'
import LoadsResource from '@/js/mixins/loads-resource'

export default {
  mixins: [HasForms, LoadsResource],
  data: () => ({
    resource: {},
    form: {},
  }),
  props: [
    'resourceName',
    'resourceId',
  ],
  computed: {},
  methods: {},
}
</script>
