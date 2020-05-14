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
            }">cancel</router-link>
          <button class="button" @click="submitResource">Save</button>
        </template>
      </panel>
    </div>
  </div>
</template>

<script>
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
  methods: {},
}
</script>
