<template>
  <div>
    <view-header>
      <template #heading>
        <slot name="heading"/>
      </template>

      <template #tools>
        <div class="mb-2">
          <slot name="tools"/>
        </div>
      </template>
    </view-header>

    <div class="bg-white rounded shadow py-4 mb-8">
      <slot name="content"/>
    </div>

    <div class="flex justify-end w-full">
      <div>
        <slot name="footer"/>
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
