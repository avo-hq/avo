<template>
  <div>
    {{field}}
  </div>
</template>

<script>
import Api from '@/js/Api'

export default {
  data: () => ({}),
  props: ['field'],
  computed: {},
  methods: {
    async getResources() {
      // const { data } = await Api.get(this.queryUrl)
      // console.log(data)
    },
  },
  async mounted() {
    console.log('has-many mounted')
    await this.getResources()
  },
}
</script>

<style lang="postcss"></style>
