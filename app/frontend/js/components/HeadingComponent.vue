<template>
  <div class="flex items-start py-1 leading-tight border-t bg-gray-700 text-white text-xs">
    <div class="p-3 pl-6 h-full w-full">
      <template v-if="value">
        <p v-if="asHtml" v-html="value"></p>
        <div v-else v-text="value" class="font-semibold uppercase"></div>
      </template>
      <empty-dash v-else />
    </div>
  </div>
</template>

<script>
export default {
  props: {
    value: String,
    asHtml: Boolean,
  },
}
</script>
