<template>
  <div class="application-sidebar flex h-full bg-white text-white w-56 z-50 border-r border-gray-400">
    <div class="w-full">
      <router-link to="/" class="logo-placeholder h-16 bg-white p-2 flex justify-center" :active-class="''" exact>
        <slot />
      </router-link>

      <div class="tools py-4">
        <sidebar-link to="/"
          exact
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
  props: ['resources'],
}
</script>

<style slang="postcss">
  .application-sidebar {
    .router-link-active:hover,
    .router-link-active {
      @apply bg-gray-200;
    }
  }
</style>
