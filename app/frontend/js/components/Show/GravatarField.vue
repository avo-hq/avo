<template>
  <show-field-wrapper :field="field" :index="index">
    <GravatarComponent
      :hashed-email="this.field.value"
      :default="this.field.default"
    />
  </show-field-wrapper>
</template>

<script>
import GravatarComponent from '@/js/components/GravatarComponent.vue'

export default {
  props: ['field', 'index'],
  components: { GravatarComponent },
}
</script>
