module Avo
  module ApplicationHelper
    include Avo::ResourcesHelper
    include Avo::SummaryChartHelper

    def ui = Avo::UIInstance

    def render_license_warning(title: "", message: "", icon: "exclamation")
      render partial: "avo/sidebar/license_warning", locals: {
        title: title,
        message: message,
        icon: icon
      }
    end

    def empty_state(**args)
      render Avo::EmptyStateComponent.new(**args)
    end

    def a_button(**args, &block)
      render Avo::ButtonComponent.new(is_link: false, **args) do
        capture(&block) if block.present?
      end
    end

    def a_link(path = nil, **args, &block)
      render Avo::ButtonComponent.new(path, is_link: true, **args) do
        capture(&block) if block.present?
      end
    end

    def button_classes(extra_classes = nil, color: nil, variant: nil, size: :md, active: false)
      classes = "inline-flex grow-0 items-center text-sm font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 rounded-sm transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer disabled:cursor-not-allowed #{extra_classes}"

      if color.present?
        if variant.present? && (variant.to_sym == :outlined)
          classes += " bg-white border"

          classes += " hover:border-#{color}-700 border-#{color}-500 text-#{color}-600 hover:text-#{color}-700 disabled:border-gray-300 disabled:text-gray-600"
        else
          classes += " text-white bg-#{color}-500 hover:bg-#{color}-600 disabled:bg-#{color}-300"
        end
      else
        classes += " text-gray-700 bg-white hover:bg-gray-100 disabled:bg-gray-300"
      end

      size = size.present? ? size.to_sym : :md
      classes += case size
      when :xs
        " p-2 py-1"
      when :sm
        " py-1 px-4"
      when :md
        " py-2 px-4"
      when :xl
        " py-3 px-4"
      else
        " p-4"
      end

      classes
    end

    def input_classes(extra_classes = "", has_error: false, size: :md)
      classes = ""
      classes += "input--size-#{size}" if [:sm, :md, :lg].include?(size)
      classes += " input-field--error" if has_error
      classes += " #{extra_classes}"
      classes.strip
    end

    def get_model_class(model)
      if model.instance_of?(Class)
        model
      else
        model.class
      end
    end

    def root_path_without_url
      "#{Avo.configuration.prefix_path}#{mount_path}"
    rescue
      Avo.configuration.root_path
    end

    def mount_path
      Avo::Engine.routes.find_script_name(params.permit!.to_h.symbolize_keys)
    end

    def decode_filter_params(encoded_params)
      Avo::Filters::BaseFilter.decode_filters(encoded_params)
    end

    def encode_filter_params(filter_params)
      Avo::Filters::BaseFilter.encode_filters(filter_params)
    end

    def number_to_social(number, start_at: 10_000)
      return number_with_delimiter(number) if number < start_at

      number_to_human(number,
        precision: 1,
        significant: false,
        round_mode: :down,
        format: "%n%u",
        units: {
          thousand: "K",
          million: "M",
          billion: "B"
        })
    end

    def frame_id(resource)
      ["frame", resource.model_name.singular, resource.record_param].compact.join("-")
    end

    def chart_color(index)
      Avo.configuration.branding.chart_colors[index % Avo.configuration.branding.chart_colors.length]
    end

    def possibly_rails_authentication?
      defined?(Authentication) && Authentication.private_instance_methods.include?(:require_authentication) && Authentication.private_instance_methods.include?(:authenticated?)
    end

    def body_classes
      os_class = request.user_agent.to_s.include?("Mac") ? "os-mac" : "os-pc"

      view_class = if controller.class.superclass.to_s == "Avo::ResourcesController"
        case action_name.to_sym
        when :index
          "resource-index-view"
        when :show
          "resource-show-view"
        when :edit, :update
          "resource-edit-view"
        when :new, :create
          "resource-new-view"
        end
      end

      [os_class, view_class, *Array.wrap(Avo.configuration.body_classes)]
    end

    # Check if the current locale is RTL (Right-to-Left)
    def rtl?
      Avo.configuration.rtl?
    end

    # Returns "rtl" or "ltr" based on current locale
    def text_direction
      Avo.configuration.text_direction
    end

    def container_classes
      return "container-#{container_width_css_suffix(@container_size.to_sym)}" if @container_size.present?

      width = Avo.configuration.container_width.fetch(@view&.to_sym, :large)
      "container-#{container_width_css_suffix(width)}"
    end

    # encode & encrypt params
    def e(value)
      encrypted = Avo::Services::EncryptionService.encrypt(message: value, purpose: :return_to, serializer: Marshal)
      Base64.urlsafe_encode64(encrypted, padding: false)
    end

    # decrypt & decode params
    def d(value)
      decoded = Base64.urlsafe_decode64(value.to_s)
      Avo::Services::EncryptionService.decrypt(message: decoded, purpose: :return_to, serializer: Marshal)
    rescue
      nil
    end

    def wrap_in_modal(content)
      turbo_frame_tag Avo::MODAL_FRAME_ID do
        render(Avo::ModalComponent.new(width: :xl, body_class: "bg-application")) do |c|
          content
        end
      end
    end

    def editor_file_path(path)
      editor_url(Object.const_source_location(path.class.to_s)&.first)
    end

    def editor_url(path)
      Avo.configuration.default_editor_url.gsub("%{path}", path)
    end

    private

    def container_width_css_suffix(width)
      (width == :full) ? "full-width" : width.to_s
    end

    def avo_field(type = nil, id = nil, as: nil, view: :show, form: nil, component_options: {}, **args, &block)
      if as.present?
        id = type
        type = as
      end
      field_klass = "Avo::Fields::#{type.to_s.camelize}Field".safe_constantize
      field = field_klass.new id, form: form, view: view, **args, &block

      # Add the form record to the field so all fields have access to it.
      field.hydrate(record: form.object) if form.present?

      render field.component_for_view(view).new field: field, form: form, **component_options
    end

    def avo_show_field(id, type = nil, view: :show, **args, &block)
      avo_field(id, type, **args, view: view, &block)
    end

    def avo_edit_field(id, type = nil, view: :edit, **args, &block)
      avo_field(id, type, **args, view: view, &block)
    end

    def html_theme_classes
      classes = []
      classes << "neutral-theme-#{current_neutral}" if current_neutral != "brand"
      classes << "theme-accent-#{current_accent}" if current_accent != "neutral"

      case current_scheme
      when "dark"  then classes << "dark" << "scheme-dark"
      when "light" then classes << "scheme-light"
      else              classes << "scheme-auto"
      end

      classes
    end

    def current_neutral
      branding = Avo.configuration.branding
      value = branding.database_persistence? ? Avo::Current.theme_settings&.dig(:neutral) : cookies[:theme]
      value.presence || branding.neutral&.to_s || "brand"
    end

    def current_accent
      branding = Avo.configuration.branding
      value = branding.database_persistence? ? Avo::Current.theme_settings&.dig(:accent) : cookies[:accent_color]
      value.presence || branding.accent&.to_s || "neutral"
    end

    def current_scheme
      branding = Avo.configuration.branding
      value = branding.database_persistence? ? Avo::Current.theme_settings&.dig(:color_scheme) : cookies[:color_scheme]
      value.presence || branding.scheme.to_s
    end
  end
end
