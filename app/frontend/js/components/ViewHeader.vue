<template>
  <div>
    <heading><slot name="heading"/></heading>

    <div class="flex justify-between items-center mb-4 w-full">
      <div>
        <slot name="search"/>
      </div>
      <div>
        <slot name="tools"/>
      </div>
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
