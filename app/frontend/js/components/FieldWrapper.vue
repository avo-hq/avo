<template>
  <div class="flex border-b items-center" v-if="field">
    <div class="w-1/3 p-4">
      <slot name="label">
        {{ field.name }} <span class="text-red-600" v-if="field.required">*</span>
      </slot>
    </div>
    <div class="w-1/3">
      <slot />
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field'],
  computed: {},
  methods: {},
  mounted() { },
}
</script>

<style lang="postcss"></style>
