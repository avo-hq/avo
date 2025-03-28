module Avo
  module ApplicationHelper
    include ::Pagy::Frontend
    include Avo::ResourcesHelper

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
      classes = "inline-flex flex-grow-0 items-center text-sm font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 rounded transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer disabled:cursor-not-allowed #{extra_classes}"

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

    # Use inline_svg gem but with our own finder implementation.
    def svg(file_name, **args)
      return if file_name.blank?

      file_name = "#{file_name}.svg" unless file_name.end_with? ".svg"

      with_asset_finder(::Avo::SvgFinder) do
        inline_svg file_name, **args
      end
    end

    def input_classes(extra_classes = "", has_error: false)
      classes = "appearance-none inline-flex bg-gray-25 disabled:cursor-not-allowed text-gray-600 disabled:opacity-50 rounded py-2 px-3 leading-tight border focus:border-gray-600 focus-visible:ring-0 focus:text-gray-700 placeholder:text-gray-300"

      classes += if has_error
        " border-red-600"
      else
        " border-gray-200"
      end

      classes += " #{extra_classes}"

      classes
    end

    def white_panel_classes
      "bg-white rounded shadow-md"
    end

    def card_classes
      "bg-white rounded shadow-panel"
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

    def pagy_major_version
      return nil unless defined?(Pagy::VERSION)
      version = Pagy::VERSION&.split(".")&.first&.to_i

      return "8-or-more" if version >= 8

      version
    end

    def container_is_full_width?
      if @container_full_width.present?
        @container_full_width
      elsif Avo.configuration.full_width_container
        true
      elsif Avo.configuration.full_width_index_view && action_name.to_sym == :index && controller.class.superclass.to_s == "Avo::ResourcesController"
        true
      else
        false
      end
    end

    def container_classes
      container_is_full_width? ? "" : "2xl:container 2xl:mx-auto"
    end

    # encode & encrypt params
    def e(value)
      Avo::Services::EncryptionService.encrypt(message: value, purpose: :return_to, serializer: Marshal)
    end

    # decrypt & decode params
    def d(value)
      Avo::Services::EncryptionService.decrypt(message: value, purpose: :return_to, serializer: Marshal)
    rescue
      value
    end

    private

    # Taken from the original library
    # https://github.com/jamesmartin/inline_svg/blob/main/lib/inline_svg/action_view/helpers.rb#L76
    def with_asset_finder(asset_finder)
      Thread.current[:inline_svg_asset_finder] = asset_finder
      output = yield
      Thread.current[:inline_svg_asset_finder] = nil

      output
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

    def field_container(**args, &block)
      classes = args[:class] || ""
      classes << "flex flex-col divide-y"
      content_tag :div, **args, class: classes, &block
    end
  end
end
