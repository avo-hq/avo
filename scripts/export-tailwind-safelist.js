/* eslint-disable no-template-curly-in-string */
const fs = require('fs')
const kebabCase = require('lodash/kebabCase')
const colors = require('tailwindcss/colors')

// Dynamically built buttons need these classes in prod.
// eslint-disable-next-line max-len
const buttonClasses = ['hover:border-${color}-700', 'border-${color}-600', 'bg-${color}-500', 'hover:bg-${color}-600', 'disabled:bg-${color}-300', 'hover:text-${color}-700', 'text-${color}-600']
const ignoredButtonClasses = Object.keys(colors).map((color) => buttonClasses.map((buttonClass) => buttonClass.replace('${color}', kebabCase(color))))

// Write them into a safelist.txt file until @tailwindcss/jit supports PurgeCSS options
fs.writeFile('./safelist.txt', ignoredButtonClasses.flat().join(' '), () => {
  // eslint-disable-next-line no-console
  console.log(`Generated safelist.txt file with ${ignoredButtonClasses.flat().length} classes.`)
})
