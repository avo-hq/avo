import { Controller } from '@hotwired/stimulus'

const LOADER_CLASSES = 'absolute bg-gray-100 opacity-10 w-full h-full'

export default class extends Controller {
  static targets = ['countrySelectInput', 'citySelectInput', 'citySelectWrapper'];

  static values = {
    view: String,
  }

  // Te fields initial value
  static initialValue

  get placeholder() {
    return this.citySelectInputTarget.ariaPlaceholder
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
    // Add the controller functionality only on forms
    if (['edit', 'new'].includes(this.viewValue)) {
      this.captureTheInitialValue()

      // Trigger the change on load
      await this.onCountryChange()
    }
  }

  // Read the country select.
  // If there's any value selected show the cities and prefill them.
  async onCountryChange() {
    if (this.hasCountrySelectInputTarget && this.countrySelectInputTarget) {
      // Get the country
      const country = this.countrySelectInputTarget.value
      // Dynamically fetch the cities for this country
      const cities = await this.fetchCitiesForCountry(country)

      // Clear the select of options
      Object.keys(this.citySelectInputTarget.options).forEach(() => {
        this.citySelectInputTarget.options.remove(0)
      })

      // Add blank option
      this.citySelectInputTarget.add(new Option(this.placeholder))

      // Add the new cities
      cities.forEach((city) => {
        this.citySelectInputTarget.add(new Option(city, city))
      })

      // Check if the initial value is present in the cities array and select it.
      // If not, select the first item
      const currentOptions = Array.from(this.citySelectInputTarget.options).map((item) => item.value)
      if (currentOptions.includes(this.initialValue)) {
        this.citySelectInputTarget.value = this.initialValue
      } else {
        // Select the first item
        this.citySelectInputTarget.value = this.citySelectInputTarget.options[0].value
      }
    }
  }

  // Private

  captureTheInitialValue() {
    this.initialValue = this.citySelectInputTarget.value
  }

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
