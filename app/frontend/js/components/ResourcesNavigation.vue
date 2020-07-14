<template>
  <div>
    <sidebar-link :large="true">
      <template #icon>
        <GameBoard class="h-4 inline-block mr-2" />
      </template>
      Resources
    </sidebar-link>

    <div class="resources-links w-full">
      <sidebar-link
        v-for="resource in sortedResources"
        :key="resource.resource_name"
        v-text="resource.label"
        class="pl-10"
        :to="{
          name: 'index',
          params: {
            resourceName: resource.resource_name,
          },
        }"
      />
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
