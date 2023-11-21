const plugin = require('tailwindcss/plugin')
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

const { primary, blue, gray } = require('./tailwind.custom')
const avoPath = require('child_process').execSync('bundle show avo', { encoding: 'utf-8' }).trim()

function contentPaths(basePath) {
  return [
    `${basePath}/safelist.txt`,
    `${basePath}/lib/avo/**/*.rb`,
    `${basePath}/app/helpers/**/*.rb`,
    `${basePath}/app/views/**/*.erb`,
    `${basePath}/app/javascript/**/*.js`,
    `${basePath}/app/components/**/*.{html.erb,rb}`,
    `${basePath}/app/controllers/**/*.rb`,
    `${basePath}/lib/**/*.rb`,
    `${basePath}/public/**/*.{js,css}`,
  ]
}

module.exports = {
  content: [
    ...contentPaths('./tmp/avo/packages/*'),
    ...contentPaths(avoPath),
  ],
  theme: {
    extend: {
      colors: {
        blue,
        gray,
        primary,
        sky: colors.sky,
        teal: colors.teal,
        slate: colors.slate,
        indigo: colors.indigo,
        application: 'rgb(var(--color-application-background))',
      },
      fontFamily: {
        // eslint-disable-next-line max-len
        sans: '"Inter", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",  "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"',
      },
      inset: {
        '1/2': '50%',
        full: '100%',
      },
      borderRadius: {
        xl: '1rem',
      },
      boxShadow: {
        row: '0 0 15px -5px rgba(0, 0, 0, 0.25)',
        context: '0 20px 25px -5px rgba(0, 0, 0, 0.25), 0 0 25px -5px rgba(0, 0, 0, 0.1)',
        panel: '0px 4px 8px rgba(0, 0, 0, 0.04), 0px 0px 2px rgba(0, 0, 0, 0.06), 0px 0px 1px rgba(0, 0, 0, 0.04)',
        modal: ' 0px 24px 32px rgba(0, 0, 0, 0.04), 0px 16px 24px rgba(0, 0, 0, 0.04), 0px 4px 8px rgba(0, 0, 0, 0.04), 0px 0px 1px rgba(0, 0, 0, 0.04)',
        stripe: '0 15px 35px #31315d1a, 0 5px 15px #00000014',
      },
      minWidth: {
        '1/2': '50%',
        '1/3': '33.333333%',
        '2/3': '66.666667%',
        '1/4': '25%',
        '2/4': '50%',
        '3/4': '75%',
        '1/5': '20%',
        '2/5': '40%',
        '3/5': '60%',
        '4/5': '80%',
      },
      maxWidth: {
        168: '42rem',
      },
      minHeight: {
        inherit: 'inherit',
        16: '4rem',
        24: '6rem',
        48: '12rem',
        '1/2': '50%',
        '1/3': '33.333333%',
        '2/3': '66.666667%',
        '1/4': '25%',
        '2/4': '50%',
        '3/4': '75%',
        '1/5': '20%',
        '2/5': '40%',
        '3/5': '60%',
        '4/5': '80%',
      },
      spacing: {
        full: '100%',
        72: '18rem',
        80: '20rem',
        88: '22rem',
        96: '24rem',
        '1/2': '50%',
        '1/3': '33.333333%',
        '2/3': '66.666667%',
        '1/4': '25%',
        '2/4': '50%',
        '3/4': '75%',
        '1/5': '20%',
        '2/5': '40%',
        '3/5': '60%',
        '4/5': '80%',
        '1/6': '16.666667%',
        '2/6': '33.333333%',
        '3/6': '50%',
        '4/6': '66.666667%',
        '5/6': '83.333333%',
        '1/12': '8.333333%',
        '2/12': '16.666667%',
        '3/12': '25%',
        '4/12': '33.333333%',
        '5/12': '41.666667%',
        '6/12': '50%',
        '7/12': '58.333333%',
        '8/12': '66.666667%',
        '9/12': '75%',
        '10/12': '83.333333%',
        '11/12': '91.666667%',
      },
      transitionTimingFunction: {
        pop: 'cubic-bezier(.23,2,.73,.55)',
      },
    },
    screens: {
      xs: '495px',
      ...defaultTheme.screens,
    },
  },
  variants: {
    display: ['responsive', 'hover', 'focus', 'group-hover', 'checked'],
    padding: ['responsive', 'group-hover'],
    borderColor: ['responsive', 'hover', 'focus', 'disabled'],
    backgroundColor: ['responsive', 'hover', 'focus', 'disabled'],
    textColor: ['responsive', 'hover', 'focus', 'disabled'],
    translate: ['responsive', 'hover', 'focus', 'active'],
    cursor: ['responsive', 'disabled'],
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    plugin(({ addUtilities }) => {
      const newUtilities = {
        '.backface-hidden': {
          backfaceVisibility: 'hidden',
        },
      }

      addUtilities(newUtilities, ['group-hover'])
    }),
  ],
}
