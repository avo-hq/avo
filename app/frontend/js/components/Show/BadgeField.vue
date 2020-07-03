<template>
  <show-field-wrapper :field="field" :index="index">
    <Badge v-if="badgeLabel"
      :type="badgeType"
      :label="badgeLabel"
    />
    <empty-dash v-else />
  </show-field-wrapper>
</template>

<script>
import Badge from '@/js/components/BadgeComponent.vue'

export default {
  props: ['field', 'index'],
  components: { Badge },
  computed: {
    badgeType() {
      return this.field.value.type
    },
    badgeLabel() {
      return this.field.value.label
    },
  },
}
</script>
