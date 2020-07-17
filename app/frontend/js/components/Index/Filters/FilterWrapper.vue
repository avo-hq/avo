<template>
  <div class="border-gray-300"
    :class="{'border-t': index !== undefined}"
  >
    <div class="p-4 pb-0 text-sm font-bold text-gray-600">
      <slot name="name" v-if="$slots.name"/>
      <div v-text="this.name" v-else />
    </div>
    <div class="p-4">
      <slot/>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: ['name', 'index'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
