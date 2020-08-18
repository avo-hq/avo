import Bus from '@/js/Bus'
import axios from 'axios'

function getCSRFToken() {
  const metaEl = document.querySelector('meta[name="csrf-token"]')

  return metaEl ? metaEl.getAttribute('content') : null
}

const appArgs = {
  baseURL: '',
  headers: {
    'X-CSRF-TOKEN': getCSRFToken(),
    'X-Requested-With': 'XMLHttpRequest',
  },
}

const Api = axios.create(appArgs)

// @todo: take redirects and reload into account before flashing toasts
Api.interceptors.response.use(
  (response) => {
    const { data } = response

    if (data) {
      const {
        message, error, redirect_url, reload,
      } = data

      if (message) Bus.$emit('message', message)
      if (error) Bus.$emit('error', error)
      if (reload) Bus.$emit('reload')
      // eslint-disable-next-line camelcase
      if (redirect_url) Bus.$emit('redirect', redirect_url)
    }

    return response
  },
  (error) => {
    const { response } = error
    const { data } = response

    if (data && data.message) {
      Bus.$emit('error', data.message)
    } else if (data && data.exception) {
      Bus.$emit('error', /^#<(.*)>$/gm.exec(data.exception)[1])
    }

    return Promise.reject(error)
  },
)

Api.interceptors.request.use((config) => {
  document.querySelector('body').classList.add('axios-loading')

  return config
})

Api.interceptors.response.use((response) => {
  document.querySelector('body').classList.remove('axios-loading')

  return response
})


export default Api
