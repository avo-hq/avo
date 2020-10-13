/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "/packs/";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = "./frontend/packs/color_picker_field.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "./frontend/components/EditField.vue":
/*!*******************************************!*\
  !*** ./frontend/components/EditField.vue ***!
  \*******************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _EditField_vue_vue_type_template_id_d4659714___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./EditField.vue?vue&type=template&id=d4659714& */ "./frontend/components/EditField.vue?vue&type=template&id=d4659714&");
/* harmony import */ var _EditField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./EditField.vue?vue&type=script&lang=js& */ "./frontend/components/EditField.vue?vue&type=script&lang=js&");
/* empty/unused harmony star reexport *//* harmony import */ var _node_modules_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../node_modules/vue-loader/lib/runtime/componentNormalizer.js */ "./node_modules/vue-loader/lib/runtime/componentNormalizer.js");





/* normalize component */

var component = Object(_node_modules_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_2__["default"])(
  _EditField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__["default"],
  _EditField_vue_vue_type_template_id_d4659714___WEBPACK_IMPORTED_MODULE_0__["render"],
  _EditField_vue_vue_type_template_id_d4659714___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"],
  false,
  null,
  null,
  null
  
)

/* hot reload */
if (false) { var api; }
component.options.__file = "frontend/components/EditField.vue"
/* harmony default export */ __webpack_exports__["default"] = (component.exports);

/***/ }),

/***/ "./frontend/components/EditField.vue?vue&type=script&lang=js&":
/*!********************************************************************!*\
  !*** ./frontend/components/EditField.vue?vue&type=script&lang=js& ***!
  \********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _node_modules_babel_loader_lib_index_js_ref_7_0_node_modules_vue_loader_lib_index_js_vue_loader_options_EditField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../node_modules/babel-loader/lib??ref--7-0!../../node_modules/vue-loader/lib??vue-loader-options!./EditField.vue?vue&type=script&lang=js& */ "./node_modules/babel-loader/lib/index.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/EditField.vue?vue&type=script&lang=js&");
/* empty/unused harmony star reexport */ /* harmony default export */ __webpack_exports__["default"] = (_node_modules_babel_loader_lib_index_js_ref_7_0_node_modules_vue_loader_lib_index_js_vue_loader_options_EditField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__["default"]); 

/***/ }),

/***/ "./frontend/components/EditField.vue?vue&type=template&id=d4659714&":
/*!**************************************************************************!*\
  !*** ./frontend/components/EditField.vue?vue&type=template&id=d4659714& ***!
  \**************************************************************************/
/*! exports provided: render, staticRenderFns */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_EditField_vue_vue_type_template_id_d4659714___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../node_modules/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!../../node_modules/vue-loader/lib??vue-loader-options!./EditField.vue?vue&type=template&id=d4659714& */ "./node_modules/vue-loader/lib/loaders/templateLoader.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/EditField.vue?vue&type=template&id=d4659714&");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "render", function() { return _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_EditField_vue_vue_type_template_id_d4659714___WEBPACK_IMPORTED_MODULE_0__["render"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_EditField_vue_vue_type_template_id_d4659714___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"]; });



/***/ }),

/***/ "./frontend/components/IndexField.vue":
/*!********************************************!*\
  !*** ./frontend/components/IndexField.vue ***!
  \********************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _IndexField_vue_vue_type_template_id_6975da5c___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./IndexField.vue?vue&type=template&id=6975da5c& */ "./frontend/components/IndexField.vue?vue&type=template&id=6975da5c&");
/* harmony import */ var _IndexField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./IndexField.vue?vue&type=script&lang=js& */ "./frontend/components/IndexField.vue?vue&type=script&lang=js&");
/* empty/unused harmony star reexport *//* harmony import */ var _node_modules_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../node_modules/vue-loader/lib/runtime/componentNormalizer.js */ "./node_modules/vue-loader/lib/runtime/componentNormalizer.js");





/* normalize component */

var component = Object(_node_modules_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_2__["default"])(
  _IndexField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__["default"],
  _IndexField_vue_vue_type_template_id_6975da5c___WEBPACK_IMPORTED_MODULE_0__["render"],
  _IndexField_vue_vue_type_template_id_6975da5c___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"],
  false,
  null,
  null,
  null
  
)

/* hot reload */
if (false) { var api; }
component.options.__file = "frontend/components/IndexField.vue"
/* harmony default export */ __webpack_exports__["default"] = (component.exports);

/***/ }),

/***/ "./frontend/components/IndexField.vue?vue&type=script&lang=js&":
/*!*********************************************************************!*\
  !*** ./frontend/components/IndexField.vue?vue&type=script&lang=js& ***!
  \*********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _node_modules_babel_loader_lib_index_js_ref_7_0_node_modules_vue_loader_lib_index_js_vue_loader_options_IndexField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../node_modules/babel-loader/lib??ref--7-0!../../node_modules/vue-loader/lib??vue-loader-options!./IndexField.vue?vue&type=script&lang=js& */ "./node_modules/babel-loader/lib/index.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/IndexField.vue?vue&type=script&lang=js&");
/* empty/unused harmony star reexport */ /* harmony default export */ __webpack_exports__["default"] = (_node_modules_babel_loader_lib_index_js_ref_7_0_node_modules_vue_loader_lib_index_js_vue_loader_options_IndexField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__["default"]); 

/***/ }),

/***/ "./frontend/components/IndexField.vue?vue&type=template&id=6975da5c&":
/*!***************************************************************************!*\
  !*** ./frontend/components/IndexField.vue?vue&type=template&id=6975da5c& ***!
  \***************************************************************************/
/*! exports provided: render, staticRenderFns */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_IndexField_vue_vue_type_template_id_6975da5c___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../node_modules/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!../../node_modules/vue-loader/lib??vue-loader-options!./IndexField.vue?vue&type=template&id=6975da5c& */ "./node_modules/vue-loader/lib/loaders/templateLoader.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/IndexField.vue?vue&type=template&id=6975da5c&");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "render", function() { return _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_IndexField_vue_vue_type_template_id_6975da5c___WEBPACK_IMPORTED_MODULE_0__["render"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_IndexField_vue_vue_type_template_id_6975da5c___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"]; });



/***/ }),

/***/ "./frontend/components/ShowField.vue":
/*!*******************************************!*\
  !*** ./frontend/components/ShowField.vue ***!
  \*******************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _ShowField_vue_vue_type_template_id_19f6a8e3___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./ShowField.vue?vue&type=template&id=19f6a8e3& */ "./frontend/components/ShowField.vue?vue&type=template&id=19f6a8e3&");
/* harmony import */ var _ShowField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./ShowField.vue?vue&type=script&lang=js& */ "./frontend/components/ShowField.vue?vue&type=script&lang=js&");
/* empty/unused harmony star reexport *//* harmony import */ var _node_modules_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../../node_modules/vue-loader/lib/runtime/componentNormalizer.js */ "./node_modules/vue-loader/lib/runtime/componentNormalizer.js");





/* normalize component */

var component = Object(_node_modules_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_2__["default"])(
  _ShowField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__["default"],
  _ShowField_vue_vue_type_template_id_19f6a8e3___WEBPACK_IMPORTED_MODULE_0__["render"],
  _ShowField_vue_vue_type_template_id_19f6a8e3___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"],
  false,
  null,
  null,
  null
  
)

/* hot reload */
if (false) { var api; }
component.options.__file = "frontend/components/ShowField.vue"
/* harmony default export */ __webpack_exports__["default"] = (component.exports);

/***/ }),

/***/ "./frontend/components/ShowField.vue?vue&type=script&lang=js&":
/*!********************************************************************!*\
  !*** ./frontend/components/ShowField.vue?vue&type=script&lang=js& ***!
  \********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _node_modules_babel_loader_lib_index_js_ref_7_0_node_modules_vue_loader_lib_index_js_vue_loader_options_ShowField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../node_modules/babel-loader/lib??ref--7-0!../../node_modules/vue-loader/lib??vue-loader-options!./ShowField.vue?vue&type=script&lang=js& */ "./node_modules/babel-loader/lib/index.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/ShowField.vue?vue&type=script&lang=js&");
/* empty/unused harmony star reexport */ /* harmony default export */ __webpack_exports__["default"] = (_node_modules_babel_loader_lib_index_js_ref_7_0_node_modules_vue_loader_lib_index_js_vue_loader_options_ShowField_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__["default"]); 

/***/ }),

/***/ "./frontend/components/ShowField.vue?vue&type=template&id=19f6a8e3&":
/*!**************************************************************************!*\
  !*** ./frontend/components/ShowField.vue?vue&type=template&id=19f6a8e3& ***!
  \**************************************************************************/
/*! exports provided: render, staticRenderFns */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_ShowField_vue_vue_type_template_id_19f6a8e3___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../node_modules/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!../../node_modules/vue-loader/lib??vue-loader-options!./ShowField.vue?vue&type=template&id=19f6a8e3& */ "./node_modules/vue-loader/lib/loaders/templateLoader.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/ShowField.vue?vue&type=template&id=19f6a8e3&");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "render", function() { return _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_ShowField_vue_vue_type_template_id_19f6a8e3___WEBPACK_IMPORTED_MODULE_0__["render"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return _node_modules_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_node_modules_vue_loader_lib_index_js_vue_loader_options_ShowField_vue_vue_type_template_id_19f6a8e3___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"]; });



/***/ }),

/***/ "./frontend/packs/color_picker_field.js":
/*!**********************************************!*\
  !*** ./frontend/packs/color_picker_field.js ***!
  \**********************************************/
/*! no exports provided */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _components_EditField_vue__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ../components/EditField.vue */ "./frontend/components/EditField.vue");
/* harmony import */ var _components_IndexField_vue__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../components/IndexField.vue */ "./frontend/components/IndexField.vue");
/* harmony import */ var _components_ShowField_vue__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../components/ShowField.vue */ "./frontend/components/ShowField.vue");



window.Avo.initializing(function (Vue) {
  Vue.component('edit-color-picker-field', _components_EditField_vue__WEBPACK_IMPORTED_MODULE_0__["default"]);
  Vue.component('index-color-picker-field', _components_IndexField_vue__WEBPACK_IMPORTED_MODULE_1__["default"]);
  Vue.component('show-color-picker-field', _components_ShowField_vue__WEBPACK_IMPORTED_MODULE_2__["default"]);
});

/***/ }),

/***/ "./node_modules/@avo-hq/avo-js/index.js":
/*!**********************************************!*\
  !*** ./node_modules/@avo-hq/avo-js/index.js ***!
  \**********************************************/
/*! exports provided: HasInputAppearance, IsFormField */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _mixins_has_input_appearance__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./mixins/has-input-appearance */ "./node_modules/@avo-hq/avo-js/mixins/has-input-appearance.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "HasInputAppearance", function() { return _mixins_has_input_appearance__WEBPACK_IMPORTED_MODULE_0__["default"]; });

/* harmony import */ var _mixins_is_form_field__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./mixins/is-form-field */ "./node_modules/@avo-hq/avo-js/mixins/is-form-field.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "IsFormField", function() { return _mixins_is_form_field__WEBPACK_IMPORTED_MODULE_1__["default"]; });





/***/ }),

/***/ "./node_modules/@avo-hq/avo-js/mixins/has-input-appearance.js":
/*!********************************************************************!*\
  !*** ./node_modules/@avo-hq/avo-js/mixins/has-input-appearance.js ***!
  \********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony default export */ __webpack_exports__["default"] = ({
  data: function data() {
    return {
      inputClasses: 'appearance-none inline-flex bg-gray-200 disabled:bg-gray-400 disabled:cursor-not-allowed focus:bg-white text-gray-700 disabled:text-gray-600 rounded-md py-3 px-3 leading-tight border border-gray-300 outline-none focus:border-gray-400 outline'
    };
  }
});

/***/ }),

/***/ "./node_modules/@avo-hq/avo-js/mixins/is-form-field.js":
/*!*************************************************************!*\
  !*** ./node_modules/@avo-hq/avo-js/mixins/is-form-field.js ***!
  \*************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var lodash_isNull__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! lodash/isNull */ "./node_modules/lodash/isNull.js");
/* harmony import */ var lodash_isNull__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(lodash_isNull__WEBPACK_IMPORTED_MODULE_0__);
/* harmony import */ var lodash_isUndefined__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! lodash/isUndefined */ "./node_modules/lodash/isUndefined.js");
/* harmony import */ var lodash_isUndefined__WEBPACK_IMPORTED_MODULE_1___default = /*#__PURE__*/__webpack_require__.n(lodash_isUndefined__WEBPACK_IMPORTED_MODULE_1__);


/* harmony default export */ __webpack_exports__["default"] = ({
  data: function data() {
    return {
      value: ''
    };
  },
  props: {
    field: {},
    resourceName: {},
    resourceId: {},
    index: {
      type: Number
    },
    errors: {
      type: Object,
      "default": function _default() {
        return {};
      }
    },
    displayedIn: {
      "default": function _default() {
        return 'form';
      }
    }
  },
  computed: {
    disabled: function disabled() {
      return this.field.readonly;
    },
    fieldError: function fieldError() {
      if (!this.hasErrors) return '';
      return "".concat(this.field.id, " ").concat(this.errors[this.field.id].join(', '));
    },
    hasErrors: function hasErrors() {
      if (lodash_isUndefined__WEBPACK_IMPORTED_MODULE_1___default()(this.errors) || lodash_isNull__WEBPACK_IMPORTED_MODULE_0___default()(this.errors) || Object.keys(this.errors).length === 0) return false;
      return !lodash_isUndefined__WEBPACK_IMPORTED_MODULE_1___default()(this.errors[this.field.id]);
    }
  },
  methods: {
    setInitialConfig: function setInitialConfig() {},
    setInitialValue: function setInitialValue() {
      this.value = this.field.value;
    },
    getValue: function getValue() {
      return this.value;
    },
    getId: function getId() {
      return this.field.id;
    },
    focus: function focus() {
      if (this.$refs['field-input']) this.$refs['field-input'].focus();
    }
  },
  created: function created() {
    this.setInitialConfig();
  },
  mounted: function mounted() {
    this.setInitialValue();
    this.field.getId = this.getId;
    this.field.getValue = this.getValue;

    if (this.index === 0) {
      this.focus();
    }
  }
});

/***/ }),

/***/ "./node_modules/babel-loader/lib/index.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/EditField.vue?vue&type=script&lang=js&":
/*!****************************************************************************************************************************************************************!*\
  !*** ./node_modules/babel-loader/lib??ref--7-0!./node_modules/vue-loader/lib??vue-loader-options!./frontend/components/EditField.vue?vue&type=script&lang=js& ***!
  \****************************************************************************************************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _avo_hq_avo_js__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @avo-hq/avo-js */ "./node_modules/@avo-hq/avo-js/index.js");
//
//
//
//
//
//
//
//
//

/* harmony default export */ __webpack_exports__["default"] = ({
  data: function data() {
    return {
      value: ''
    };
  },
  mixins: [_avo_hq_avo_js__WEBPACK_IMPORTED_MODULE_0__["HasInputAppearance"], _avo_hq_avo_js__WEBPACK_IMPORTED_MODULE_0__["IsFormField"]],
  computed: {
    classes: function classes() {
      var classes = ['w-full', 'rounded-md'];
      if (this.hasErrors) classes.push('border-red-600');
      return classes.join(' ');
    }
  },
  methods: {
    /**
     * Set the value of the field when the page is loaded.
    */
    setInitialValue: function setInitialValue() {
      this.value = this.field.value;
    },

    /**
     * Get the value of the field when the form is submitted.
    */
    getValue: function getValue() {
      return this.value;
    }
  }
});

/***/ }),

/***/ "./node_modules/babel-loader/lib/index.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/IndexField.vue?vue&type=script&lang=js&":
/*!*****************************************************************************************************************************************************************!*\
  !*** ./node_modules/babel-loader/lib??ref--7-0!./node_modules/vue-loader/lib??vue-loader-options!./frontend/components/IndexField.vue?vue&type=script&lang=js& ***!
  \*****************************************************************************************************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
//
//
//
//
//
//
//
//
//
//
//
/* harmony default export */ __webpack_exports__["default"] = ({
  data: function data() {
    return {};
  },
  props: ['field'],
  computed: {},
  methods: {},
  mounted: function mounted() {}
});

/***/ }),

/***/ "./node_modules/babel-loader/lib/index.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/ShowField.vue?vue&type=script&lang=js&":
/*!****************************************************************************************************************************************************************!*\
  !*** ./node_modules/babel-loader/lib??ref--7-0!./node_modules/vue-loader/lib??vue-loader-options!./frontend/components/ShowField.vue?vue&type=script&lang=js& ***!
  \****************************************************************************************************************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
//
//
//
//
//
//
//
//
//
//
//
/* harmony default export */ __webpack_exports__["default"] = ({
  data: function data() {
    return {};
  },
  props: ['field', 'index'],
  computed: {},
  methods: {},
  mounted: function mounted() {}
});

/***/ }),

/***/ "./node_modules/lodash/isNull.js":
/*!***************************************!*\
  !*** ./node_modules/lodash/isNull.js ***!
  \***************************************/
/*! no static exports found */
/***/ (function(module, exports) {

/**
 * Checks if `value` is `null`.
 *
 * @static
 * @memberOf _
 * @since 0.1.0
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is `null`, else `false`.
 * @example
 *
 * _.isNull(null);
 * // => true
 *
 * _.isNull(void 0);
 * // => false
 */
function isNull(value) {
  return value === null;
}

module.exports = isNull;

/***/ }),

/***/ "./node_modules/lodash/isUndefined.js":
/*!********************************************!*\
  !*** ./node_modules/lodash/isUndefined.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports) {

/**
 * Checks if `value` is `undefined`.
 *
 * @static
 * @since 0.1.0
 * @memberOf _
 * @category Lang
 * @param {*} value The value to check.
 * @returns {boolean} Returns `true` if `value` is `undefined`, else `false`.
 * @example
 *
 * _.isUndefined(void 0);
 * // => true
 *
 * _.isUndefined(null);
 * // => false
 */
function isUndefined(value) {
  return value === undefined;
}

module.exports = isUndefined;

/***/ }),

/***/ "./node_modules/vue-loader/lib/loaders/templateLoader.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/EditField.vue?vue&type=template&id=d4659714&":
/*!********************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!./node_modules/vue-loader/lib??vue-loader-options!./frontend/components/EditField.vue?vue&type=template&id=d4659714& ***!
  \********************************************************************************************************************************************************************************************************/
/*! exports provided: render, staticRenderFns */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "render", function() { return render; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return staticRenderFns; });
var render = function() {
  var _vm = this
  var _h = _vm.$createElement
  var _c = _vm._self._c || _h
  return _c(
    "edit-field-wrapper",
    { attrs: { field: _vm.field, errors: _vm.errors, index: _vm.index } },
    [
      _c("input", {
        directives: [
          {
            name: "model",
            rawName: "v-model",
            value: _vm.value,
            expression: "value"
          }
        ],
        class: _vm.classes,
        attrs: { type: "color" },
        domProps: { value: _vm.value },
        on: {
          input: function($event) {
            if ($event.target.composing) {
              return
            }
            _vm.value = $event.target.value
          }
        }
      })
    ]
  )
}
var staticRenderFns = []
render._withStripped = true



/***/ }),

/***/ "./node_modules/vue-loader/lib/loaders/templateLoader.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/IndexField.vue?vue&type=template&id=6975da5c&":
/*!*********************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!./node_modules/vue-loader/lib??vue-loader-options!./frontend/components/IndexField.vue?vue&type=template&id=6975da5c& ***!
  \*********************************************************************************************************************************************************************************************************/
/*! exports provided: render, staticRenderFns */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "render", function() { return render; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return staticRenderFns; });
var render = function() {
  var _vm = this
  var _h = _vm.$createElement
  var _c = _vm._self._c || _h
  return _c(
    "index-field-wrapper",
    { attrs: { field: _vm.field } },
    [
      _vm.field.value
        ? _c("div", {
            staticClass:
              "h-6 px-1 rounded-md text-white text-sm flex items-center justify-center leading-none",
            style: { backgroundColor: _vm.field.value },
            domProps: { textContent: _vm._s(_vm.field.value) }
          })
        : _c("empty-dash")
    ],
    1
  )
}
var staticRenderFns = []
render._withStripped = true



/***/ }),

/***/ "./node_modules/vue-loader/lib/loaders/templateLoader.js?!./node_modules/vue-loader/lib/index.js?!./frontend/components/ShowField.vue?vue&type=template&id=19f6a8e3&":
/*!********************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!./node_modules/vue-loader/lib??vue-loader-options!./frontend/components/ShowField.vue?vue&type=template&id=19f6a8e3& ***!
  \********************************************************************************************************************************************************************************************************/
/*! exports provided: render, staticRenderFns */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "render", function() { return render; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return staticRenderFns; });
var render = function() {
  var _vm = this
  var _h = _vm.$createElement
  var _c = _vm._self._c || _h
  return _c(
    "show-field-wrapper",
    { attrs: { field: _vm.field, index: _vm.index } },
    [
      _vm.field.value
        ? _c("div", {
            staticClass:
              "h-6 px-1 rounded-md text-white text-sm flex items-center justify-center leading-none",
            style: { backgroundColor: _vm.field.value },
            domProps: { textContent: _vm._s(_vm.field.value) }
          })
        : _c("empty-dash")
    ],
    1
  )
}
var staticRenderFns = []
render._withStripped = true



/***/ }),

/***/ "./node_modules/vue-loader/lib/runtime/componentNormalizer.js":
/*!********************************************************************!*\
  !*** ./node_modules/vue-loader/lib/runtime/componentNormalizer.js ***!
  \********************************************************************/
/*! exports provided: default */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "default", function() { return normalizeComponent; });
/* globals __VUE_SSR_CONTEXT__ */

// IMPORTANT: Do NOT use ES2015 features in this file (except for modules).
// This module is a runtime utility for cleaner component module output and will
// be included in the final webpack user bundle.

function normalizeComponent (
  scriptExports,
  render,
  staticRenderFns,
  functionalTemplate,
  injectStyles,
  scopeId,
  moduleIdentifier, /* server only */
  shadowMode /* vue-cli only */
) {
  // Vue.extend constructor export interop
  var options = typeof scriptExports === 'function'
    ? scriptExports.options
    : scriptExports

  // render functions
  if (render) {
    options.render = render
    options.staticRenderFns = staticRenderFns
    options._compiled = true
  }

  // functional template
  if (functionalTemplate) {
    options.functional = true
  }

  // scopedId
  if (scopeId) {
    options._scopeId = 'data-v-' + scopeId
  }

  var hook
  if (moduleIdentifier) { // server build
    hook = function (context) {
      // 2.3 injection
      context =
        context || // cached call
        (this.$vnode && this.$vnode.ssrContext) || // stateful
        (this.parent && this.parent.$vnode && this.parent.$vnode.ssrContext) // functional
      // 2.2 with runInNewContext: true
      if (!context && typeof __VUE_SSR_CONTEXT__ !== 'undefined') {
        context = __VUE_SSR_CONTEXT__
      }
      // inject component styles
      if (injectStyles) {
        injectStyles.call(this, context)
      }
      // register component module identifier for async chunk inferrence
      if (context && context._registeredComponents) {
        context._registeredComponents.add(moduleIdentifier)
      }
    }
    // used by ssr in case component is cached and beforeCreate
    // never gets called
    options._ssrRegister = hook
  } else if (injectStyles) {
    hook = shadowMode
      ? function () {
        injectStyles.call(
          this,
          (options.functional ? this.parent : this).$root.$options.shadowRoot
        )
      }
      : injectStyles
  }

  if (hook) {
    if (options.functional) {
      // for template-only hot-reload because in that case the render fn doesn't
      // go through the normalizer
      options._injectStyles = hook
      // register for functional component in vue file
      var originalRender = options.render
      options.render = function renderWithStyleInjection (h, context) {
        hook.call(context)
        return originalRender(h, context)
      }
    } else {
      // inject component registration as beforeCreate hook
      var existing = options.beforeCreate
      options.beforeCreate = existing
        ? [].concat(existing, hook)
        : [hook]
    }
  }

  return {
    exports: scriptExports,
    options: options
  }
}


/***/ })

/******/ });
//# sourceMappingURL=color_picker_field-f18a74736d3130694f23.js.map