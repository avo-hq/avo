<template>
  <div class="w-full h-full flex flex-col justify-between">
    <div class="p-4 text-xl" v-if="heading">
      {{ heading }}
    </div>
    <div class="flex-1 flex items-center justify-center px-8 text-lg">
      {{ text }}
    </div>
    <div class="flex justify-end space-x-4 p-4 bg-gray-200">
      <button
        v-if="confirmAction"
        @click="$emit('close')"
      >
        Cancel
      </button>
      <button
        ref="confirm-button"
        class="button border-red-700 text-red-700"
        v-if="confirmAction"
        @click="confirmAction"
      >
        Confirm
      </button>
    </div>
  </div>
</template>

<script>
export default {
  props: ['heading', 'text', 'confirmAction'],
  mounted() {
    this.$refs['confirm-button'].focus()
  },
}
</script>
