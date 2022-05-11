/* eslint-disable global-require */
const plugin = require('tailwindcss/plugin')
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

const primary = {
  50: '#E6F3FC',
  100: '#CEE7F8',
  150: '#B5DBF5',
  200: '#9CCFF2',
  300: '#6BB6EB',
  400: '#399EE5',
  500: '#0886DE',
  600: '#066BB2',
  700: '#055085',
  800: '#033659',
  850: '#022843',
  900: '#021B2C',
}

const gray = {
  25: '#F6F6F7',
  50: '#F1F2F3',
  100: '#E3E5E8',
  150: '#D6D8DC',
  200: '#C8CBD0',
  300: '#ACB1B9',
  400: '#9197A1',
  500: '#757D8A',
  600: '#5E646E',
  700: '#464B53',
  800: '#2F3237',
  850: '#232629',
  900: '#17191C',
}

module.exports = {
  mode: 'jit',
  future: {},
  content: [
    './safelist.txt',
    './lib/avo/**/*.rb',

    './app/helpers/**/*.rb',
    './app/views/**/*.erb',
    './app/javascript/**/*.js',
    './app/components/avo/**/*.erb',
    './app/components/avo/**/*.rb',
    './app/controllers/avo/**/*.rb',
    './app/javascript/**/*.js',

    './spec/dummy/app/avo/resources/**/*.rb',
    './spec/dummy/app/views/**/*.erb',
  ],

  theme: {
    extend: {
      colors: {
        slate: colors.slate,
        sky: colors.sky,
        teal: colors.teal,
        indigo: colors.indigo,
        blue: primary,
        primary,
        ternary: gray,
        gray,
        application: '#e5ebf0',
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
