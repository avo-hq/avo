const plugin = require('tailwindcss/plugin')

module.exports = {
  purge: [
    './app/helpers/**/*.rb',
    './app/views/**/*.html',
    './app/views/**/*.html.erb',
    './app/frontend/**/*.vue',
    './app/frontend/**/*.js',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: '"Lato", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",  "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"',
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
        panel: '0 0 20px -5px rgba(0, 0, 0, 0.1)',
      },
      minWidth: {
        '300px': '300px',
        4: '1rem',
        10: '2.5rem',
      },
      minHeight: {
        28: '7rem',
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
    },
  },
  variants: {
    display: ['responsive', 'hover', 'focus', 'group-hover'],
    borderColor: ['responsive', 'hover', 'focus', 'disabled'],
    backgroundColor: ['responsive', 'hover', 'focus', 'disabled'],
    textColor: ['responsive', 'hover', 'focus', 'disabled'],
    translate: ['responsive', 'hover', 'focus', 'active'],
    cursor: ['responsive', 'disabled'],
  },
  plugins: [
    // buttons
    plugin(({ addComponents, theme }) => {
      const styles = {
        display: 'inline-flex',
        flexGrow: 0,
        alignItems: 'center',
        fontSize: theme('fontSize.md'),
        fontWeight: theme('fontWeight.semibold'),
        lineHeight: 1,
        padding: `${theme('spacing.2')} ${theme('spacing.4')}`,
        fill: 'currentColor',
        whiteSpace: 'nowrap',
        backgroundColor: theme('colors.white'),
        color: theme('colors.gray.900'),
        border: `1px solid ${theme('colors.gray.100')}`,
        transitionProperty: theme('transitionProperty.default'),
        transitionDuration: theme('transitionDuration.100'),
        borderRadius: theme('borderRadius.default'),
        boxShadow: theme('boxShadow.default'),
        '&:hover': {
          backgroundColor: theme('colors.gray.100'),
        },
        '&:active': {
          backgroundColor: theme('colors.gray.200'),
        },
      }
      const buttons = {
        '@variants responsive': {
          '.button': {
            ...styles,
            '&.button-lg': {
              padding: `${theme('spacing.3')} ${theme('spacing.6')}`,
              fontSize: theme('fontSize.lg'),
            },
            '&.button-sm': {
              padding: `${theme('spacing.1')} ${theme('spacing.2')}`,
              fontSize: theme('fontSize.sm'),
            },
            '&.button-xl': {
              padding: `${theme('spacing.4')} ${theme('spacing.10')}`,
              fontSize: theme('fontSize.2xl'),
            },
          },
          '.button-indigo': {
            ...styles,
            color: theme('colors.white'),
            backgroundColor: theme('colors.indigo.600'),
            '&:hover': {
              backgroundColor: theme('colors.indigo.700'),
            },
            '&:active': {
              backgroundColor: theme('colors.indigo.800'),
            },
            '&1active': {
              backgroundColor: theme('colors.indigo.800'),
            },
          },
        },
      }

      addComponents(buttons)
    }),
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
