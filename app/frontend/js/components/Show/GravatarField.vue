<template>
  <show-field-wrapper :field="field" :index="index">
    <GravatarComponent
      :hashedEmail="this.field.value"
      :rounded="this.field.rounded"
      :squared="this.field.squared"
      :size="this.field.size"
      :defaultUrl="this.field.default_url"
      >
    </GravatarComponent>
  </show-field-wrapper>
</template>

<script>
/* eslint-disable import/no-unresolved */
import GravatarComponent from '@/js/components/GravatarComponent'

export default {
  props: ['field', 'index'],
  components: { GravatarComponent },
}
</script>
