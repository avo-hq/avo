<template>
  <index-field-wrapper :field="field">
    <span v-if="field.value" :class="classes">{{ field.value }}</span>
    <div v-else>
      -
    </div>
  </index-field-wrapper>
</template>

<script>
export default {
  props: ['field'],
  computed: {
    classes() {
      let classes = []

      // default styling
      if (this.field.map[this.field.value] === 'info') classes.push('rounded-full bg-blue-500 uppercase px-2 py-1 text-xs font-bold text-white')
      if (this.field.map[this.field.value] === 'success') classes.push('rounded-full bg-green-500 uppercase px-2 py-1 text-xs font-bold text-white')
      if (this.field.map[this.field.value] === 'danger') classes.push('rounded-full bg-red-500 uppercase px-2 py-1 text-xs font-bold text-white')
      if (this.field.map[this.field.value] === 'warning') classes.push('rounded-full bg-yellow-500 uppercase px-2 py-1 text-xs font-bold text-white')

      // // override default styling
      // if (this.field.styles[this.field.value]) {
      //   classes = []
      //   classes.push(this.field.styles[this.field.value])
      // }

      // // add more styling
      // if (this.field.add_styles[this.field.value]) {
      //   classes.push(this.field.add_styles[this.field.value])
      // }

      return classes.join(' ')
    },
  },
}
</script>
