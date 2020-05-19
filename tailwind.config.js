const plugin = require('tailwindcss/plugin')

module.exports = {
  purge: [
    './src/**/*.html',
    './src/**/*.html.erb',
    './src/**/*.vue',
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
        4: '1rem',
        8: '2rem',
        12: '3rem',
        '300px': '300px',
      },
    },
  },
  variants: {},
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
    // form fields
    plugin(({ addComponents, theme }) => {
      const components = {
        'input[type=email], input[type=password], textarea, input[type=text], input[type=number]': {
          appearance: 'none',
          display: 'inline-flex',
          backgroundColor: theme('colors.white'),
          color: theme('colors.gray.700'),
          borderStyle: 'solid',
          borderWidth: '1px',
          borderColor: theme('colors.gray.300'),
          borderRadius: theme('borderRadius.default'),
          padding: `${theme('spacing.2')} ${theme('spacing.4')}`,
          lineHeight: theme('lineHeight.tight'),
          '&:focus': {
            outline: 'none',
            backgroundColor: theme('colors.white'),
            borderColor: theme('colors.gray.500'),
          },
          '&:disabled': {
            backgroundColor: theme('colors.gray.200'),
          },
        },
      }

      addComponents(components)
    }),
    // labels
    plugin(({ addComponents, theme }) => {
      const styles = {
        display: 'inline-flex',
        textTransform: 'uppercase',
        letterSpacing: theme('letterSpacing.wide'),
        color: theme('color.gray.700'),
        fontSize: theme('fontSize.xs'),
        fontWeight: theme('fontWeight.bold'),
        marginBottom: theme('spacing.2'),
      }
      const components = {
        label: {
          ...styles,
        },
      }

      addComponents(components)
    }),
    // select
    plugin(({ addComponents, theme }) => {
      const styles = {
        appearance: 'none',
        display: 'inline-flex',
        borderStyle: 'solid',
        borderWidth: '1px',
        borderColor: theme('colors.gray.300'),
        backgroundColor: theme('colors.white'),
        color: theme('colors.gray.700'),
        padding: `${theme('spacing.2')} ${theme('spacing.8')} ${theme('spacing.2')} ${theme('spacing.4')}`,
        borderRadius: theme('borderRadius.default'),
        lineHeight: theme('lineHeight.tight'),
        backgroundRepeat: 'no-repeat',
        backgroundPosition: 'right .5rem center',
        backgroundImage: 'url(data:image/svg+xml;base64,PHN2ZyBhcmlhLWhpZGRlbj0idHJ1ZSIgZm9jdXNhYmxlPSJmYWxzZSIgZGF0YS1wcmVmaXg9ImZhZCIgZGF0YS1pY29uPSJjaGV2cm9uLWRvd24iIHJvbGU9ImltZyIgaGVpZ2h0PSIxNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2aWV3Qm94PSIwIDAgNDQ4IDUxMiIgY2xhc3M9InN2Zy1pbmxpbmUtLWZhIGZhLWNoZXZyb24tZG93biBmYS13LTE0IGZhLTd4Ij48ZyBjbGFzcz0iZmEtZ3JvdXAiPjxwYXRoIGZpbGw9ImN1cnJlbnRDb2xvciIgZD0iTTIyNC4xIDI4NC42NGwtNTYuODkgNTYuNzgtMTU0LTE1NC4zMWEyNCAyNCAwIDAgMSAwLTMzLjk0bDIyLjY1LTIyLjdhMjMuOTMgMjMuOTMgMCAwIDEgMzMuODQgMHoiIGNsYXNzPSJmYS1zZWNvbmRhcnkiPjwvcGF0aD48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik00MzUgMTg3LjE1TDI0MSAzODEuNDhhMjMuOTQgMjMuOTQgMCAwIDEtMzMuODQgMGwtNDAtNDAgMjExLjM0LTIxMWEyMy45MyAyMy45MyAwIDAgMSAzMy44NCAwTDQzNSAxNTMuMjFhMjQgMjQgMCAwIDEgMCAzMy45NHoiIGNsYXNzPSJmYS1wcmltYXJ5Ij48L3BhdGg+PC9nPjwvc3ZnPg==)',
        '&:focus': {
          outline: 'none',
          backgroundColor: theme('colors.white'),
          borderColor: theme('colors.gray.500'),
        },
      }
      const components = {
        select: {
          ...styles,
        },
      }

      addComponents(components)
    }),
  ],
}
