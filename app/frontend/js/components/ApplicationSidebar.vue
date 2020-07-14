<template>
  <div class="application-sidebar flex h-full bg-gray-700 text-white w-56 z-50 text-sm">
    <div class="w-full">
      <logo-component :logo="logo"/>

      <div class="tools">
        <sidebar-link to="/"
          exact
          class="mt-4 mb-0 pl-10"
        >
          Dashboard
        </sidebar-link>

        <resources-navigation :resources="resources"/>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ['logo', 'resources'],
}
</script>

<style slang="postcss">
  .application-sidebar {
    .router-link-active:hover,
    .router-link-active {
      @apply font-bold;
    }
  }
</style>
