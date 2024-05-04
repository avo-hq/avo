import BaseFilterController from './filter_controller';
import noUiSlider from 'nouislider';

export default class extends BaseFilterController {
  static targets = ['rangeSlider'];
  sliderInitialized = false;
  slider = null;

  connect() {
    this.initializeSlider();
    this.checkResetFilter();
  }

  initializeSlider() {
    if (!this.sliderInitialized) {
      let sliderElement = document.getElementById('range-slider-filter');
      let savedValue = sessionStorage.getItem('sliderValue');
      savedValue = savedValue ? JSON.parse(savedValue) : [1, 65];

      // 既存のスライダーがあれば削除する
      if (this.slider) {
        this.slider.destroy();
      }

      this.slider = noUiSlider.create(sliderElement, {
        start: savedValue,
        connect: true,
        tooltips: true,
        range: {min: 1, max: 65},
        format: {
          to: function(value) {
            if (value >= 65) {
              return '上限なし';
            }
            return Math.floor(value) + '分';
          },
          from: function(value) {
            if (value === '上限なし') {
              return 65;
            }
            return Number(value.replace('分', ''));
          },
        },
      });

      this.slider.on('change', (values, handle) => {
        sessionStorage.setItem('sliderValue', JSON.stringify(values));
        this.changeFilter();
      });

      this.sliderInitialized = true;
    }
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
    let defaultValues = [1, 65];
    this.slider.set(defaultValues);
    sessionStorage.setItem('sliderValue', JSON.stringify(defaultValues));
  }

  getFilterValue() {
    let values = this.slider.get();
    return values.map(value => {
      return value.includes('分') ? value.replace('分', '') : value;
    });
  }

  getFilterClass() {
    return 'Avo::Filters::SliderVideoDurationFilter';
  }
}
