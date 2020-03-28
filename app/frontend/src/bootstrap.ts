import axios from "axios";
import _ from "lodash";
import { Bus } from "./bus";

declare global {
    interface Window {
        _: any;
        axios: any;
    }
}

window._ = _;

window.axios = axios;
window.axios.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest";

// Add a response interceptor
axios.interceptors.response.use(
  function(response) {
      if (response.data) {
          if (response &&
              response.data &&
              response.data.redirect_url &&
              _.isString(response.data.redirect_url)) {
              location.href = response.data.redirect_url;
          }
          if (response.data && response.data.alert && _.isObject(response.data.alert)) {
              Bus.$emit("alert", response.data.alert);
          }
      }
      return response;
  },
  error => {
      if (error) {
          if (error.response &&
              error.response.data &&
              error.response.data.redirect_url &&
              _.isString(error.response.data.redirect_url)) {
              location.href = error.response.data.redirect_url;
          }

          if (error.response && error.response.data && _.isObject(error.response.data)) {
              Bus.$emit("error", error.response.data);
          }

          if (axios.isCancel(error)) {
              return error.message;
          }
      }
      return Promise.reject(error);
  }
);