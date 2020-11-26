<template>
  <div class="relative flex-1 py-12">
    <div class="relative block text-gray-300 h-64 w-full">
      <avocado-icon :class="centeringClasses"
        class="h-20 text-gray-400"
      />
      <code-icon :class="centeringClasses"
        class="h-8 -ml-20 -mt-12"
      />
      <fire-icon :class="centeringClasses"
        class="h-8 -ml-10 -mt-24"
      />
      <color-swatch-icon :class="centeringClasses"
        class="h-8 ml-8 -mt-24"
      />
      <globe-icon :class="centeringClasses"
        class="h-8 ml-20 -mt-12"
      />
      <library-icon :class="centeringClasses"
        class="h-8 -ml-20 mt-4"
      />
      <photograph-icon :class="centeringClasses"
        class="h-8 ml-20 mt-4"
      />
    </div>
    <div class="relative block text-center text-lg text-gray-600 font-semibold -mt-10" v-text="label" />
  </div>
</template>

<script>
export default {
  data: () => ({
    centeringClasses: 'absolute inset-auto left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2',
  }),
  props: [
    'resourceName',
    'viaResourceName',
  ],
  computed: {
    label() {
      if (this.viaResourceName) return this.$t('avo.no_related_item_found', { item: this.resourceName.toLowerCase() })

      return this.$t('avo.no_item_found', { item: this.resourceName.toLowerCase() })
    },
  },
}
</script>
