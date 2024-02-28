const plugin = require('tailwindcss/plugin')
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

const avoPath = require('child_process').execSync('bundle show avo', { encoding: 'utf-8' }).trim()
const {
  primary, neutral, blue, gray,
} = require('./tailwind.custom')

function contentPaths(basePath) {
  return [
    `${basePath}/safelist.txt`,
    `${basePath}/lib/avo/**/*.rb`,
    `${basePath}/app/helpers/**/*.rb`,
    `${basePath}/app/views/**/*.{html.erb,rb}`,
    `${basePath}/app/javascript/**/*.js`,
    `${basePath}/app/components/**/*.{html.erb,rb}`,
    `${basePath}/app/controllers/**/*.rb`,
    `${basePath}/lib/**/*.rb`,
    `${basePath}/public/**/*.{js,css}`,
  ]
}

module.exports = {
  darkMode: 'class',
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
        neutral,
        sky: colors.sky,
        teal: colors.teal,
        slate: colors.slate,
        indigo: colors.indigo,
        application: 'rgb(var(--color-application-background))',
        // accent: {
        //   50: 'var(--color-accent-50, var(--color-primary-50))',
        //   100: 'var(--color-accent-100, var(--color-primary-100))',
        //   150: 'var(--color-accent-150, var(--color-primary-150))',
        //   200: 'var(--color-accent-200, var(--color-primary-200))',
        //   300: 'var(--color-accent-300, var(--color-primary-300))',
        //   400: 'var(--color-accent-400, var(--color-primary-400))',
        //   500: 'var(--color-accent-500, var(--color-primary-500))',
        //   600: 'var(--color-accent-600, var(--color-primary-600))',
        //   700: 'var(--color-accent-700, var(--color-primary-700))',
        //   800: 'var(--color-accent-800, var(--color-primary-800))',
        //   850: 'var(--color-accent-850, var(--color-primary-850))',
        //   900: 'var(--color-accent-900, var(--color-primary-900))',
        // },
        // neutral: {
        //   50: 'var(--color-neutral-50)',
        //   100: 'var(--color-neutral-100)',
        //   150: 'var(--color-neutral-150)',
        //   200: 'var(--color-neutral-200)',
        //   300: 'var(--color-neutral-300)',
        //   400: 'var(--color-neutral-400)',
        //   500: 'var(--color-neutral-500)',
        //   600: 'var(--color-neutral-600)',
        //   700: 'var(--color-neutral-700)',
        //   800: 'var(--color-neutral-800)',
        //   850: 'var(--color-neutral-850)',
        //   900: 'var(--color-neutral-900)',
        // },
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
        panel: 'var(--border-radius-panel)',
      },
      borderWidth: {
        stroke: 'var(--stroke-width)',
      },
      padding: {
        'index-field-wrapper': 'var(--padding-index-field-wrapper)',
        'field-wrapper-x': 'var(--padding-field-wrapper-x)',
        'field-wrapper-y': 'var(--padding-field-wrapper-y)',
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
