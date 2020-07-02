import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'

Vue.use(Vuex)

const state = {
  appliedFilters: {},
}

const index = {
  namespaced: true,
  state,
  getters: {},
  actions: {},
  mutations: {},
}

export default new Vuex.Store({
  modules: {
    index,
  },
})
