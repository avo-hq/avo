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
    uniqSliderId: String,
  };
  slider = null;

  connect() {
    this.checkResetFilter();
    this.slider.on('change', (values) => {
      sessionStorage.setItem('sliderValue' + this.uniqSliderIdValue, JSON.stringify(values));
      this.changeFilter();
    });
  }

  initialize() {
    let sliderElement = document.getElementById('range-slider-filter-' + this.uniqSliderIdValue);
    let savedValue = sessionStorage.getItem('sliderValue' + this.uniqSliderIdValue);
    savedValue = savedValue ? JSON.parse(savedValue) : [this.minValue, this.maxValue];
    this.slider = noUiSlider.create(sliderElement, this.setupSlider(savedValue));
  }

  setupSlider(savedValue) {
    return {
      start: savedValue,
      connect: true,
      tooltips: true,
      range: {
        min: this.minValue,
        max: this.maxValue,
      },
      format: {
        to: (value) => value >= this.maxValue ?
          this.maxWordValue :
          Math.floor(value) + this.suffixValue,
        from: (value) => value === this.maxWordValue ?
          this.maxValue :
          Number(value.replace(this.suffixValue, '')),
      },
    };
  }

  checkResetFilter() {
    let urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('reset_filter') === 'true' && !urlParams.get('encoded_filters')) {
      sessionStorage.removeItem('sliderValue' + this.uniqSliderIdValue);
      this.resetSlider();
    }
  }

  resetSlider() {
    let defaultValues = [this.minValue, this.maxValue];
    this.slider.set(defaultValues);
    sessionStorage.removeItem('sliderValue' + this.uniqSliderIdValue);
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
