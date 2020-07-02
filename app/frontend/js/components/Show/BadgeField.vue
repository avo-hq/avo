<template>
  <show-field-wrapper :field="field" :index="index">
    <span v-if="field.value" :class="classes">{{ badgeLabel }}</span>
    <div v-else>
      -
    </div>
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    badgeType() {
      return this.field.value.type
    },
    badgeLabel() {
      return this.field.value.label
    },
    classes() {
      const classes = ['rounded-full', 'uppercase', 'px-2', 'text-xs', 'font-bold', 'text-white']

      const backgrounds = {
        info: 'blue',
        success: 'green',
        danger: 'red',
        warning: 'yellow',
      }

      classes.push(`bg-${backgrounds[this.badgeType]}-500`)

      return classes.join(' ')
    },
  },
}
</script>
