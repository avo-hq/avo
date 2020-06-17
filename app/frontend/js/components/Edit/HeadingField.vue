<template>
  <div class="flex items-start py-2 leading-tight border-t bg-gray-200">
    <div class="p-4 h-full w-full">
      <template v-if="field.name">
          <p v-if="!this.field.as_html" v-text="field.name"></p>
          <div v-else v-html="field.name"></div>
      </template>
      <p v-else>-</p>
    </div>
  </div>
</template>

<script>
export default {
  props: ['field'],
}
</script>
