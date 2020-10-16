<template>
  <div
    :is="element"
    :to="to"
    :exact="exact"
    :class="classes"
  >
    <div class="w-4">
      <slot name="icon" v-if="this.$slots.icon"/>
    </div>
    <slot/>
  </div>
</template>

<script>
export default {
  props: ['to', 'label', 'exact', 'icon', 'large'],
  computed: {
    classes() {
      if (this.large) return 'flex items-center my-2 p-3 text-gray-500 font-bold text-sm -mb-1 leading-none'

      return 'text-gray-800 py-2 px-4 block font-normal hover:bg-gray-100 rounded-md mb-1 mx-3 text-sm leading-none'
    },
    element() {
      if (this.to) return 'router-link'

      return 'div'
    },
  },
}
</script>
