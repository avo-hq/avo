const initialState = {
  availableResources: [],
}

const mutations = {
  setAvailableResources(state, availableResources) {
    state.availableResources = availableResources
  },
}

const actions = {}

const store = {
  namespaced: true,
  state: initialState,
  mutations,
  actions,
}

export default store
