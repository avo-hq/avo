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
  slider = null;

  connect() {
    this.checkResetFilter();
  }

  initialize() {
    let sliderElement = document.getElementById('range-slider-filter');
    let savedValue = sessionStorage.getItem('sliderValue');
    savedValue = savedValue ? JSON.parse(savedValue) : [this.minValue, this.maxValue];
    this.slider = noUiSlider.create(sliderElement, this.setupSlider(savedValue));
    this.slider.on('change', (values) => {
        sessionStorage.setItem('sliderValue', JSON.stringify(values));
        this.changeFilter();
      });
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
