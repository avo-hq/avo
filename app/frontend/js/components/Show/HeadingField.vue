<template>
  <HeadingComponent
    :value="this.field.name"
    :asHtml="this.field.as_html"
    :class="{'overflow-hidden rounded-t-xl': index === 0}"
    >
  </HeadingComponent>
</template>

<script>
import HeadingComponent from '@/js/components/HeadingComponent.vue'

export default {
  props: ['field', 'index'],
  components: { HeadingComponent },
}
</script>
