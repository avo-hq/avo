<template>
  <router-link :to="to" class="text-white text-lg font-bold p-2 block hover:bg-gray-800" :exact="exact"><slot/></router-link>
</template>

<script>
export default {
  props: ['to', 'label', 'exact'],
}
</script>
