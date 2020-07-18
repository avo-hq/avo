<template>
  <td class="px-4 py-2 leading-tight whitespace-no-wrap h-12">
    <slot/>
  </td>
</template>

<script>
export default {
  props: ['field'],
}
</script>
