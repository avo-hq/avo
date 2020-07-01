<template>
  <index-field-wrapper :field="field">
    <GravatarComponent
      :hashedEmail="this.field.value"
      :squared="this.field.squared"
      :size="this.field.size"
      :defaultUrl="this.field.default_url"
      >
    </GravatarComponent>
  </index-field-wrapper>
</template>

<script>
/* eslint-disable import/no-unresolved */
import GravatarComponent from '@/js/components/GravatarComponent'

export default {
  props: ['field'],
  components: { GravatarComponent },
}
</script>
