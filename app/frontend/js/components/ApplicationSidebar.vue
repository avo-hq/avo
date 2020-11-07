<template>
  <div class="application-sidebar flex h-full bg-white text-white w-56 z-50 border-r border-gray-400">
    <div class="flex flex-col w-full">
      <router-link to="/"
        class="logo-placeholder h-16 bg-white p-2 flex justify-center"
        :active-class="''"
        exact
      >
        <slot name="logo"/>
      </router-link>

      <div class="flex-1 flex flex-col justify-between">
        <div class="tools py-4">
          <sidebar-link to="/"
            exact
          >
            {{ $t('avo.dashboard') }}
          </sidebar-link>

          <resources-navigation />
        </div>

        <slot name="licensing"/>
      </div>
    </div>
  </div>
</template>

<style slang="postcss">
  .application-sidebar {
    .router-link-active:hover,
    .router-link-active {
      @apply bg-gray-200;
    }
  }
</style>
