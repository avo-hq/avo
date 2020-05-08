<template>
  <div>
    <heading><slot name="heading"/></heading>

    <div>
      <slot name="tools"/>
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: [],
  computed: {},
  methods: {},
  mounted() {},
}
</script>

<style lang="postcss"></style>
