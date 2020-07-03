<template>
  <td class="px-2 py-2 leading-tight whitespace-no-wrap">
    <slot/>
  </td>
</template>

<script>
export default {
  props: ['field'],
}
</script>
