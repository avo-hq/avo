<template>
  <HeadingComponent
    :value="this.field.name"
    :asHtml="this.field.as_html"
    >
  </HeadingComponent>
</template>

<script>
/* eslint-disable import/no-unresolved */
import HeadingComponent from '@/js/components/HeadingComponent'

export default {
  props: ['field'],
  components: { HeadingComponent },
}
</script>
