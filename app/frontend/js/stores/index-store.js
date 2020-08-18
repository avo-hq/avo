const initialState = {
  selectedResources: [],
}

const mutations = {
  updateSelection(state, resource) {
    const currentIndex = state.selectedResources.indexOf(resource.id)
    const itemSelected = currentIndex !== -1

    if (itemSelected) {
      state.selectedResources.splice(currentIndex, 1)
    } else {
      state.selectedResources.push(resource.id)
    }
  },
  clearSelectedResources(state) {
    state.selectedResources = []
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
