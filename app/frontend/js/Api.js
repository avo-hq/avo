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
  ({ response }) => {
    const { data } = response

    console.log(data.exception)
    if (data && data.exception) Bus.$emit('error', "#<ActiveRecord::RecordInvalid: Validation failed: Email can't be blank, Password can't be blank>")
    if (data && data.exception) Bus.$emit('error', data.exception.toString())
  },
)

export default Api
