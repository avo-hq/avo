import * as Mousetrap from 'mousetrap';
import * as Turbolinks from 'turbolinks';
import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm.js'
import Vuex from 'vuex'

Vue.use(Vuex);
Vue.use(TurbolinksAdapter)

// import {store} from '@/src/store'

Mousetrap.bind('r r r', () => Turbolinks.visit(window.location.href));

document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    el: '#app',
    // store,
    data: () => {
      return {
        message: "Can you say hello?"
      }
    },
    methods: {
      reload() {
        Turbolinks.visit(window.location.href);
      },
    },
    mounted() {
      this.$on('reload', this.reload)
    },
    destroyed() {
      this.$off('reload')
    },
  })
})
