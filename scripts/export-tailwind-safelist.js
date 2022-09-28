/* eslint-disable no-template-curly-in-string */
const fs = require('fs')
const kebabCase = require('lodash/kebabCase')
const colors = require('tailwindcss/colors')

// Dynamically built buttons need these classes in prod.
const buttonClasses = [
  'bg-${color}-500',
  'border-${color}-500',
  'hover:bg-${color}-600',
  'hover:border-${color}-600',
  'active:border-${color}-600',
  'active:outline-${color}-600',
  'active:bg-${color}-600',
  'text-${color}-500',
  'hover:bg-${color}-100',
  'active:bg-${color}-100',
  'active:border-${color}-500',
  'active:outline-${color}-500',
]

const buttonColors = Object.keys(colors)
buttonColors.push('primary')
buttonColors.push('text-white')

const ignoredButtonClasses = buttonColors.map((color) => buttonClasses.map((buttonClass) => buttonClass.replace('${color}', kebabCase(color))))

// Add the whitespace class for newlines
ignoredButtonClasses.push('whitespace-pre-line')

// Write them into a safelist.txt file until @tailwindcss/jit supports PurgeCSS options
fs.writeFile('./safelist.txt', ignoredButtonClasses.flat().join(' '), () => {
  // eslint-disable-next-line no-console
  console.log(`Generated safelist.txt file with ${ignoredButtonClasses.flat().length} classes.`)
})
