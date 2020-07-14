<template>
  <div
    :is="element"
    :to="to"
    :exact="exact"
    :class="classes"
  >
    <div class="w-8" v-if="this.$slots.icon">
      <slot name="icon"/>
    </div>
    <slot/>
  </div>
</template>

<script>
export default {
  props: ['to', 'label', 'exact', 'icon', 'large'],
  computed: {
    classes() {
      if (this.large) return 'flex items-center my-2 uppercase tracking-normal p-2 text-white font-bold'

      return 'text-white px-2 py-1 block hover:text-gray-500'
    },
    element() {
      if (this.to) return 'router-link'

      return 'div'
    },
  },
}
</script>
