<template>
  <index-field-wrapper :field="field">
    <GravatarComponent
      :hashed-email="this.field.value"
      :rounded="this.field.rounded"
      :size="this.field.size"
      :default="this.field.default"
    />
  </index-field-wrapper>
</template>

<script>
import GravatarComponent from '@/js/components/GravatarComponent.vue'

export default {
  props: ['field'],
  components: { GravatarComponent },
}
</script>
