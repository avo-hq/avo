require_dependency "avo/application_controller"

module Avo
  class PrivateController < ApplicationController
    before_action :authenticate_developer_or_admin!

    def design
      @page_title = "Design [Private]"
    end

    def branding
      @page_title = "Color Tokens [Private]"

      @light_foundations = [
        {name: "--color-background", value: "var(--color-avo-neutral-25)", desc: "Page background"},
        {name: "--color-foreground", value: "var(--color-avo-neutral-800)", desc: "Text foreground"},
        {name: "--color-primary", value: "var(--color-white)", desc: "Primary surface"},
        {name: "--color-secondary", value: "var(--color-avo-neutral-50)", desc: "Secondary surface"},
        {name: "--color-tertiary", value: "var(--color-avo-neutral-100)", desc: "Tertiary surface"},
        {name: "--color-content", value: "var(--color-avo-neutral-950)", desc: "Text content"},
        {name: "--color-content-secondary", value: "var(--color-avo-neutral-500)", desc: "Secondary text"}
      ]

      @dark_foundations = [
        {name: "--color-background", value: "var(--color-avo-neutral-900)", desc: "Page background"},
        {name: "--color-foreground", value: "var(--color-avo-neutral-50)", desc: "Text foreground"},
        {name: "--color-primary", value: "var(--color-avo-neutral-950)", desc: "Primary surface"},
        {name: "--color-secondary", value: "var(--color-avo-neutral-800)", desc: "Secondary surface"},
        {name: "--color-tertiary", value: "var(--color-avo-neutral-700)", desc: "Tertiary surface"},
        {name: "--color-content", value: "var(--color-white)", desc: "Text content"},
        {name: "--color-content-secondary", value: "var(--color-avo-neutral-300)", desc: "Secondary text"}
      ]

      @neutral_scale = [
        {name: "25", oklch: "oklch(98.51% 0.0000 89.88)"},
        {name: "50", oklch: "oklch(97.31% 0.0000 89.88)"},
        {name: "100", oklch: "oklch(92.80% 0.0000 89.88)"},
        {name: "200", oklch: "oklch(86.07% 0.0000 89.88)"},
        {name: "300", oklch: "oklch(75.72% 0.0000 89.88)"},
        {name: "400", oklch: "oklch(62.68% 0.0000 89.88)"},
        {name: "500", oklch: "oklch(53.48% 0.0000 89.88)"},
        {name: "600", oklch: "oklch(47.84% 0.0000 89.88)"},
        {name: "700", oklch: "oklch(42.76% 0.0000 89.88)"},
        {name: "800", oklch: "oklch(39.04% 0.0000 89.88)"},
        {name: "900", oklch: "oklch(27.68% 0.0000 89.88)"},
        {name: "950", oklch: "oklch(20.46% 0.0000 89.88)"}
      ]

      @light_accents = [
        {name: "--color-accent", value: "var(--color-avo-neutral-800)", desc: "Accent"},
        {name: "--color-accent-content", value: "var(--color-avo-neutral-950)", desc: "Accent subtle"},
        {name: "--color-accent-foreground", value: "var(--color-white)", desc: "Accent text"}
      ]

      @dark_accents = [
        {name: "--color-accent", value: "var(--color-avo-neutral-50)", desc: "Accent"},
        {name: "--color-accent-content", value: "var(--color-avo-neutral-100)", desc: "Accent subtle"},
        {name: "--color-accent-foreground", value: "var(--color-avo-neutral-950)", desc: "Accent text"}
      ]

      @accent_options = [
        {name: "red"},
        {name: "orange"},
        {name: "amber"},
        {name: "yellow"},
        {name: "lime"},
        {name: "green"},
        {name: "emerald"},
        {name: "teal"},
        {name: "cyan"},
        {name: "sky"},
        {name: "blue"},
        {name: "indigo"},
        {name: "violet"},
        {name: "purple"},
        {name: "fuchsia"},
        {name: "pink"},
        {name: "rose"}
      ]
    end
  end
end
