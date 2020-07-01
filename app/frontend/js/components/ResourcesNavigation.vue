<template>
  <div>
    <div class="flex items-center font-bold mb-2 uppercase tracking-normal p-2 text-blue-200 text-sm">
      <GameBoard class="h-4 inline-block mr-2" /> Resources
    </div>

    <div class="resources-links w-full">
      <sidebar-link
        v-for="resource in sortedResources"
        :key="resource.resource_name"
        v-text="resource.label"
        :to="{
          name: 'index',
          params: {
            resourceName: resource.resource_name,
          },
        }"></sidebar-link>
    </div>
  </div>
</template>

<script>
import GameBoard from '@/svgs/game-board.svg?inline'
import sortBy from 'lodash/sortBy'

export default {
  components: { GameBoard },
  props: ['resources'],
  computed: {
    sortedResources() {
      return sortBy(this.resources, 'resource_name')
    },
  },
}
</script>

<style slang="postcss"></style>
