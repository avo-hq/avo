<template>
  <index-field-wrapper :field="field">
    <Badge v-if="badgeLabel"
      :type="badgeType"
      :label="badgeLabel"
    />
    <div v-else>-</div>
  </index-field-wrapper>
</template>

<script>
import Badge from '@/js/components/BadgeComponent.vue'

export default {
  props: ['field'],
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
