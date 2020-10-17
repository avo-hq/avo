<template>
  <div v-if="!hidden">
    <div v-if="noResources">
      <pane class="p-6">
        <heading class="mb-4">
          Welcome to Avo 🥑
        </heading>

        <p class="mb-2">
          You haven't generated any Resources. <strong>Resources</strong> are the backbone of Avo.
        </p>

        <p class="mb-2">
          To generate a resource run this command.
        </p>

        <div class="mb-2 mt-4">
          <code class="block bg-gray-200 px-3 py-2 rounded text-gray-800">bin/rails generate avo:resource Post</code>
        </div>
      </pane>
    </div>
    <div v-else>
      <div class="mb-4 text-lg font-bold">
        Current resources
      </div>
      <div class="grid grid-cols-3 gap-x-6">
        <div v-for="resource in resources" :key="resource.name">
          <pane class="p-6">
            <div class="font-semibold leading-tight mb-2 text-lg">
              {{resource.count}} {{resource.name | pluralize(resource.count) | capitalize()}}
            </div>
            <div class="flex justify-end">
              <router-link :to="{
                name: 'index',
                params: {
                  resourceName: resource.url,
                },
              }"
              >view all</router-link>
            </div>
          </pane>
        </div>
      </div>
    </div>
    <pane class="p-6" v-if="!hideDocs">
      Read the <a href="https://docs.avohq.io" target="_blank">docs</a> for options on how to customize resources.
    </pane>
  </div>
</template>

<script>
import Api from '@/js/Api'
import Avo from '@/js/Avo'
import pluralize from 'pluralize'

export default {
  data: () => ({
    resources: [],
    hidden: true,
    hideDocs: false,
  }),
  props: [],
  filters: {
    pluralize(value, count) {
      return pluralize(value, count)
    },
    capitalize(value) {
      return value.charAt(0).toUpperCase() + value.slice(1)
    },
  },
  computed: {
    noResources() {
      return this.resources.length === 0
    },
  },
  methods: {
    async getResources() {
      const { data } = await Api.get(`${Avo.rootPath}/avo-tools/resource-overview`)
      this.resources = data.resources
      this.hidden = data.hidden
      this.hideDocs = data.hide_docs
    },
  },
  async mounted() {
    await this.getResources()
  },
}
</script>
