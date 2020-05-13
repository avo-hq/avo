<template>
  <div class="application-sidebar flex h-full block bg-gray-700 text-white w-64 z-50">
    <div class="w-full">
      <logo-component :logo="logo"/>
      <div class="tools">
        <div>
          <sidebar-link to="/" exact>Dashboard</sidebar-link>
        </div>
        <resources-navigation :resources="resources"/>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: ['logo', 'resources'],
  computed: {},
  methods: {},
  mounted() { },
}
</script>

<style slang="postcss">
  .application-sidebar {
    .router-link-active:hover,
    .router-link-active {
      @apply bg-gray-900;
    }
  }
</style>
