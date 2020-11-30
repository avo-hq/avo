<template>
  <router-link to="/" class="h-16 bg-white p-2 flex justify-center" :active-class="''" exact>
    <template v-if="hasLogo" />
    <template v-else>
      <img src="@/images/logo.png" alt="Avo" class="h-full">
    </template>
  </router-link>
</template>

<script>
import isUndefined from 'lodash/isUndefined'

export default {
  props: ['logo'],
  computed: {
    hasLogo() {
      return !isUndefined(this.logo)
    },
  },
}
</script>
