<template>
  <show-field-wrapper :field="field" :index="index">
    <span v-if="field.value" :class="classes">{{ field.value }}</span>
    <div v-else>
      -
    </div>
  </show-field-wrapper>
</template>

<script>
export default {
  props: ['field', 'index'],
  computed: {
    classes() {
      const classes = []
      const value = this.field.map[this.field.value.toLowerCase()]

      if (value === 'info') classes.push('rounded-full bg-blue-500 uppercase px-2 py-1 text-xs font-bold text-white')
      if (value === 'success') classes.push('rounded-full bg-green-500 uppercase px-2 py-1 text-xs font-bold text-white')
      if (value === 'danger') classes.push('rounded-full bg-red-500 uppercase px-2 py-1 text-xs font-bold text-white')
      if (value === 'warning') classes.push('rounded-full bg-yellow-500 uppercase px-2 py-1 text-xs font-bold text-white')

      return classes.join(' ')
    },
  },
}
</script>
