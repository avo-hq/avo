<template>
  <div>
    <div class="font-bold text-2xl mb-4">Resources</div>

    <div class="pl-4 resources-links w-full">
      <router-link
        v-for="resource in resources"
        :key="resource.resource_name"
        v-text="resource.label"
        class="text-white font-semibold p-2 block rounded-lg"
        :test="`resource-navication-${resource.resource_name}`"
        :to="{
          name: 'index',
          params: {
            resourceName: resource.resource_name,
          },
        }"></router-link>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: ['resources'],
  computed: {},
  methods: {},
  mounted() {
    console.log('this.resources->', this.resources)
  },
}
</script>

<style slang="postcss">
  .resources-links {
    a {
      &.router-link-active {
        @apply bg-blue-900;
      }
    }
  }
</style>
