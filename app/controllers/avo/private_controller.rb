require_dependency "avo/application_controller"

module Avo
  class PrivateController < ApplicationController
    before_action :authenticate_developer_or_admin!

    def design
      @page_title = "Design [Private]"
    end

    def appearance
      @page_title = "Color Tokens [Private]"

      @foundation_tokens = [
        {name: "--color-background", desc: "Page background"},
        {name: "--color-foreground", desc: "Text foreground"},
        {name: "--color-primary", desc: "Primary surface"},
        {name: "--color-secondary", desc: "Secondary surface"},
        {name: "--color-tertiary", desc: "Tertiary surface"},
        {name: "--color-content", desc: "Text content"},
        {name: "--color-content-secondary", desc: "Secondary text"}
      ]

      @neutral_scale = Avo::Configuration::Appearance::NEUTRAL_SHADES.map do |shade|
        {name: shade.to_s, css_var: "--color-avo-neutral-#{shade}"}
      end

      @accent_tokens = [
        {name: "--color-accent", value: "var(--color-accent)", desc: "Accent"},
        {name: "--color-accent-content", value: "var(--color-accent-content)", desc: "Accent subtle"},
        {name: "--color-accent-foreground", value: "var(--color-accent-foreground)", desc: "Accent text"}
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
