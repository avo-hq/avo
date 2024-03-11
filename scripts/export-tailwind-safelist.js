/**
  This command should only be run when updating one of the dynamic components or when we add a suport for a custom class on the docs.
  EX: - Avo::ButtonComponent
*/

/* eslint-disable no-template-curly-in-string */
const fs = require('fs')
const kebabCase = require('lodash/kebabCase')
const colors = require('tailwindcss/colors')

// Dynamically-built buttons need these classes in prod.
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
buttonColors.push(
  'primary',
  'text-white',
)

const ignoredDynamicClasses = buttonColors.map((color) => buttonClasses.map((buttonClass) => buttonClass.replace('${color}', kebabCase(color))))

// Add the whitespace class for newlines and text alignment
ignoredDynamicClasses.push(
  'whitespace-pre-line',
  'text-right',
  'text-left',
  'text-center',
  'font-sans',
  'font-serif',
  'font-mono',
  // avo-pro drag and drop feature:
  '!bg-gray-100',
  'opacity-50',
  'select-none',
)

// Add the backgrounds colors that are used by the charts
const chartColors = ['#0B8AE2', '#34C683', '#FFBE4F', '#FF7676', '#2AB1EE', '#34C6A8', '#EC8CFF', '#80FF91', '#FFFC38', '#1BDBE8']
chartColors.forEach((color) => {
  ignoredDynamicClasses.push(`bg-[${color}]`)
})

const content = `# This file was auto-generated using the \`yarn export:tailwind-safelist\` command in \`export-tailwind-safelist.js\`\n${ignoredDynamicClasses.flat().join(' ')}`

// Write them into a safelist.txt file until @tailwindcss/jit supports PurgeCSS options
fs.writeFile('./safelist.txt', content, () => {
  // eslint-disable-next-line no-console
  console.log(`Generated safelist.txt file with ${ignoredDynamicClasses.flat().length} classes.`)
})
