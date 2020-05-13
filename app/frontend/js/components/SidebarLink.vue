<template>
  <router-link :to="to" class="text-white text-lg font-bold p-2 block" :exact="exact"><slot/></router-link>
</template>

<script>
export default {
  data: () => ({}),
  props: ['to', 'label', 'exact'],
  computed: {},
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
