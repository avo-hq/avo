<template>
  <div class="flex items-start py-2 leading-tight border-t bg-gray-200">
    <div class="p-4 h-full w-full">
      <template v-if="value">
          <p v-if="asHtml" v-html="value"></p>
          <div v-else v-text="value" class="font-semibold uppercase"></div>
      </template>
      <p v-else>-</p>
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
