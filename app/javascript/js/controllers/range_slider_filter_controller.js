import BaseFilterController from './filter_controller';
import noUiSlider from 'nouislider';

export default class extends BaseFilterController {
  static targets = ['rangeSlider'];
  static values = {
    min: Number,
    max: Number,
    suffix: String,
    maxWord: String,
    filterClass: String,
  };
  sliderInitialized = false;
  slider = null;

  connect() {
    this.checkResetFilter();
  }

  initialize() {
    let min = this.minValue;
    let max = this.maxValue;
    let suffix = this.suffixValue;
    let maxWord = this.maxWordValue;
    let sliderElement = document.getElementById('range-slider-filter');
    let savedValue = sessionStorage.getItem('sliderValue');
    savedValue = savedValue ? JSON.parse(savedValue) : [min, max];
      this.slider = noUiSlider.create(sliderElement, {
        start: savedValue,
        connect: true,
        tooltips: true,
        range: {min: min, max: max},
        format: {
          to: function(value) {
            if (value >= max) {
              return maxWord;
            }
            return Math.floor(value) + suffix;
          },
          from: function(value) {
            if (value === maxWord) {
              return max;
            }
            return Number(value.replace(suffix, ''));
          },
        },
      });

    this.slider.on('change', (values) => {
        sessionStorage.setItem('sliderValue', JSON.stringify(values));
        this.changeFilter();
      });
    // this.sliderInitialized = true;
  }

  checkResetFilter() {
    const urlParams = new URLSearchParams(window.location.search);
    const resetFilter = urlParams.get('reset_filter');
    const encodedFilters = urlParams.get('encoded_filters');

    if (resetFilter === 'true' && !encodedFilters) {
      sessionStorage.removeItem('sliderValue');
      this.resetSlider();
    }
  }

  resetSlider() {
    let defaultValues = [this.minValue, this.maxValue];
    this.slider.set(defaultValues);
    sessionStorage.setItem('sliderValue', JSON.stringify(defaultValues));
  }

  getFilterValue() {
    return this.slider.get().map(value => {
      return value.includes(this.suffixValue) ?
        value.replace(this.suffixValue, '') : value;
    });
  }

  getFilterClass() {
    return this.filterClassValue;
  }
}
