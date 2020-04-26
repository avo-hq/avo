<template>
  <div>
    <div class="font-bold text-2xl mb-4">Resources</div>

    <div class="pl-4 resources-links w-full">
      <router-link
        v-for="resource in resources"
        :key="resource.url"
        v-text="resource.name"
        class="text-white font-semibold p-2 block rounded-lg"
        :to="{
          name: 'index',
          params: {
            resourceName: resource.name,
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

<style>
.resources-links {
  a {
    &.router-link-active {
      @apply bg-blue-900;
    }
  }
}
</style>
