<template>
  <div :class="classes" v-if="field">
    <div class="w-1/3 p-4">
      <slot name="label">
        {{ field.name }} <span class="text-red-600" v-if="field.required">*</span>
      </slot>
    </div>
    <div class="w-1/3 py-4">
      <slot />
    </div>
  </div>
</template>

<script>
export default {
  data: () => ({}),
  props: ['field', 'index'],
  computed: {
    classes() {
      const classes = ['flex', 'items-center', 'py-2', 'leading-tight']

      if (this.index !== 0) classes.push('border-t')

      return classes.join(' ')
    },
  },
  methods: {},
  mounted() { },
}
</script>

<style lang="postcss"></style>
