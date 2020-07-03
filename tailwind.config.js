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
        sans: '"Mukta", system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",  "Helvetica Neue", Arial, "Noto Sans", sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji"',
      },
      inset: {
        full: '100%',
      },
      minWidth: {
        '300px': '300px',
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
      },
    },
  },
  variants: {
    display: ['responsive', 'hover', 'focus', 'group-hover'],
    borderColor: ['responsive', 'hover', 'focus', 'disabled'],
    backgroundColor: ['responsive', 'hover', 'focus', 'disabled'],
    textColor: ['responsive', 'hover', 'focus', 'disabled'],
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
