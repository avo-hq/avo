class Avo::Configuration::Theme

  # --boxes-border-radius: var(--radius-sm);
  # --fields-border-radius: var(--radius-sm);
  # --selectors-border-radius: var(--radius-sm);

  # --depth-effect: 0;
  # --noise-effect: 0;

  # --field-base-size: 3px; /* 3px-5px */
  # --selectors-base-size: 3px; /* 3px-5px */

  # --border-width: 1px; /* 0.5px-2px */

  # /* Colors */
  # --color-base-100: #f0f0f0;
  # --color-base-200: #f0f0f0;
  # --color-base-300: #f0f0f0;
  # --color-text: #f0f0f0;

  # --color-primary-content: #f0f0f0;
  # --color-primary-text: #f0f0f0;
  # --color-secondary-content: #f0f0f0;
  # --color-secondary-text: #f0f0f0;
  # --color-accent-content: #f0f0f0;
  # --color-accent-text: #f0f0f0;
  # --color-neutral-content: #f0f0f0;
  # --color-neutral-text: #f0f0f0;
  # --color-info-content: #f0f0f0;
  # --color-info-text: #f0f0f0;
  # --color-success-content: #f0f0f0;
  # --color-success-text: #f0f0f0;
  # --color-warning-content: #f0f0f0;
  # --color-warning-text: #f0f0f0;
  # --color-error-content: #f0f0f0;
  # --color-error-text: #f0f0f0;
  def initialize
    puts ["initialize->"].inspect
    @initial_values = {
      "--color-base-100": "var(--color-neutral-100)",
      "--color-base-200": "var(--color-neutral-300)",
      "--color-base-300": "var(--color-neutral-500)",
      "--color-text": "var(--color-neutral-700)",

      "--color-input-text": "var(--color-neutral-600)",
      "--color-input-bg": "var(--color-neutral-50)",
      "--color-input-focused-text": "var(--color-neutral-700)",
      "--color-input-focused-ring": "var(--color-primary-content)",

      # color_application: "--avo-color-application-background",

      # boxes_border_radius: "4px",
      # fields_border_radius: "4px",
      # selectors_border_radius: "4px",

      # depth_effect: 0,
      # noise_effect: 0,
      # field_base_size: 3,
      # selectors_base_size: 3,
      # border_width: 1,

      # color_input_bg: "#f0f0f0",
      # color_placeholder: "#f0f0f0",

      # color_base_100: "#f0f0f0",
      # color_base_200: "#f0f0f0",
      # color_base_300: "#f0f0f0",
      # color_text: "#f0f0f0",
      # color_primary_content: "#f0f0f0",
      # color_primary_text: "#f0f0f0",
      # color_secondary_content: "#f0f0f0",
      # color_secondary_text: "#f0f0f0",
      # color_accent_content: "#f0f0f0",
      # color_accent_text: "#f0f0f0",
      # color_neutral_content: "#f0f0f0",
      # color_neutral_text: "#f0f0f0",

      # color_info_content: "#f0f0f0",
      # color_info_text: "#f0f0f0",
      # color_success_content: "#f0f0f0",
      # color_success_text: "#f0f0f0",
      # color_warning_content: "#f0f0f0",
      # color_warning_text: "#f0f0f0",
      # color_error_content: "#f0f0f0",
    }.stringify_keys

    @variables = @initial_values.dup
  end

  # @name: "#radius-{key}"
  BORDER_RADIUS = {
    "none": 0,
    "sm": "4px",
    "lg": "8px",
    "2xl": "16px",
    "4xl": "32px",
  }

  def to_s
    @variables.map do |key, value|
      next if value.blank?

      "#{key}: #{value};"
    end.join("\n")
  end

  def set_variable(property: nil, value: nil)
    # name = css_name.to_s.gsub("--", "").gsub("-", "_").to_sym
    # puts ["@variables[name]->", @variables[name]].inspect
    @variables[property] = value
    puts ["property->", property, @variables[property]].inspect
  end

  def reset_variable(property: nil)
    # name = css_name.to_s.gsub("--", "").gsub("-", "_").to_sym
    # puts ["@variables[name]->", @variables[name]].inspect
    @variables[property] = @initial_values[property]
    puts ["property->", property, @variables[property]].inspect
  end

  def get_variable(property)
    @variables[property.to_s]
  end

  def get_initial_value(property)
    @initial_values[property.to_s]
  end

  # def css_colors
  #   rgb_colors.map do |color, value|
  #     if color == :background
  #       "--avo-color-application-background: #{value};"
  #     else
  #       "--avo-color-primary-#{color}: #{value};"
  #     end
  #   end.join("\n")
  # end

  # def logo
  #   @logo || @default_logo
  # end

  # def logomark
  #   @logomark || @default_logomark
  # end

  # def placeholder
  #   @placeholder || @default_placeholder
  # end

  # def chart_colors
  #   @chart_colors || @default_chart_colors
  # end

  # def favicon
  #   @favicon || @default_favicon
  # end

  # private

  # def colors
  #   @default_colors.merge(@colors) || @default_colors
  # end

  # def rgb_colors
  #   colors.map do |key, value|
  #     rgb_value = is_hex?(value) ? hex_to_rgb(value) : value
  #     [key, rgb_value]
  #   end.to_h
  # end

  # def is_hex?(value)
  #   value.include? "#"
  # end

  # def hex_to_rgb(value)
  #   value.to_s.match(/^#(..)(..)(..)$/).captures.map(&:hex).join(" ")
  # end
end
