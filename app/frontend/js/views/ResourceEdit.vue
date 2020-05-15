<template>
  <div v-if="resource">
    <div v-for="panel in resource.panels" :key="panel.name">
      <panel>
        <template #heading>
            Edit {{resourceNameSingular}}
        </template>

        <template #content>
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
              name: 'show',
              params: {
                resourceName: resourceName,
                resourceId: resource.id,
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
    resource: null,
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
