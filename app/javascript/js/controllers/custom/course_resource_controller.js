import { Controller } from '@hotwired/stimulus'

const LOADER_CLASSES = 'absolute bg-gray-100 opacity-10 w-full h-full'

export default class extends Controller {
  static targets = ['countryFieldInput', 'cityFieldInput', 'citySelectWrapper'];

  static values = {
    view: String,
  }

  // Te fields initial value
  static initialValue

  get placeholder() {
    return this.cityFieldInputTarget.ariaPlaceholder
  }

  set loading(isLoading) {
    if (isLoading) {
      // create a loader overlay
      const loadingDiv = document.createElement('div')
      loadingDiv.className = LOADER_CLASSES
      loadingDiv.dataset.target = 'city-loader'

      // add the loader overlay
      this.citySelectWrapperTarget.prepend(loadingDiv)
      this.citySelectWrapperTarget.classList.add('opacity-50')
    } else {
      // remove the loader overlay
      this.citySelectWrapperTarget.querySelector('[data-target="city-loader"]').remove()
      this.citySelectWrapperTarget.classList.remove('opacity-50')
    }
  }

  async connect() {
    if (['edit', 'new'].includes(this.viewValue)) {
      this.captureTheInitialValue()

      await this.countryChanged()
    }
  }

  captureTheInitialValue() {
    this.initialValue = this.cityFieldInputTarget.value
  }

  // Read the country select.
  // If there's any value selected show the cities and prefill them.
  async countryChanged() {
    if (this.hasCountryFieldInputTarget && this.countryFieldInputTarget) {
      // Get the country
      const country = this.countryFieldInputTarget.value
      // Dynamically fetch the cities for this country
      const cities = await this.fetchCitiesForCountry(country)

      // Clear the select of options
      Object.keys(this.cityFieldInputTarget.options).forEach(() => {
        this.cityFieldInputTarget.options.remove(0)
      })

      // Add blank option
      this.cityFieldInputTarget.add(new Option(this.placeholder))

      // Add the new cities
      cities.forEach((city) => {
        this.cityFieldInputTarget.add(new Option(city, city))
      })

      // Check if the initial value is present in the cities array and select it.
      // If not, select the first item
      const currentOptions = Array.from(this.cityFieldInputTarget.options).map((item) => item.value)
      if (currentOptions.includes(this.initialValue)) {
        this.cityFieldInputTarget.value = this.initialValue
      } else {
        // Select the first item
        this.cityFieldInputTarget.value = this.cityFieldInputTarget.options[0].value
      }
    }
  }

  // Private

  async fetchCitiesForCountry(country) {
    if (!country) {
      return []
    }

    this.loading = true

    const response = await fetch(
      `${window.Avo.configuration.root_path}/resources/courses/cities?country=${country}`,
    )
    const data = await response.json()

    this.loading = false

    return data
  }
}
