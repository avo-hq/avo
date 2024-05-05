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
      // Store the current slider values in sessionStorage
      sessionStorage.setItem('sliderValue' + this.uniqSliderIdValue, JSON.stringify(values));
      this.changeFilter();
    });
  }

  initialize() {
    let sliderElement = document.getElementById('range-slider-filter-' + this.uniqSliderIdValue);
    // Retrieve saved values from sessionStorage or use default values
    let savedValue = sessionStorage.getItem('sliderValue' + this.uniqSliderIdValue);
    savedValue = savedValue ? JSON.parse(savedValue) : [this.minValue, this.maxValue];
    // Create a new noUiSlider instance with the saved or default values
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
    // Check URL parameters for reset conditions
    let urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('reset_filter') === 'true' && !urlParams.get('encoded_filters')) {
      // Clear saved slider values if reset conditions are met
      sessionStorage.removeItem('sliderValue' + this.uniqSliderIdValue);
      this.resetSlider();
    }
  }

  resetSlider() {
    // Reset the slider to its default values
    let defaultValues = [this.minValue, this.maxValue];
    this.slider.set(defaultValues);
    sessionStorage.removeItem('sliderValue' + this.uniqSliderIdValue);
  }

  getFilterValue() {
    // Retrieve the current values from the slider and remove any suffixes
    return this.slider.get().map(value => {
      return value.includes(this.suffixValue) ?
        value.replace(this.suffixValue, '') : value;
    });
  }

  getFilterClass() {
    return this.filterClassValue;
  }
}
