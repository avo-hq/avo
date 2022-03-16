module Avo
  module ApplicationHelper
    include ::Pagy::Frontend

    def render_license_warnings
      render partial: "avo/sidebar/license_warnings", locals: {
        license: Avo::App.license.properties
      }
    end

    def render_license_warning(title: "", message: "", icon: "exclamation")
      render partial: "avo/sidebar/license_warning", locals: {
        title: title,
        message: message,
        icon: icon
      }
    end

    def empty_state(**args)
      render Avo::EmptyStateComponent.new **args
    end

    def turbo_frame_wrap(name, &block)
      render Avo::TurboFrameWrapperComponent.new name do
        capture(&block)
      end
    end

    def a_button(**args, &block)
      render Avo::ButtonComponent.new(is_link: false, **args) do
        capture(&block) if block_given?
      end
    end

    def a_link(path = nil, **args, &block)
      render Avo::ButtonComponent.new(path, is_link: true, **args) do
        capture(&block) if block_given?
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

    def svg(file_name, **args)
      options = {}
      options[:class] = args[:class].present? ? args[:class] : ""
      options[:class] += args[:extra_class].present? ? " #{args[:extra_class]}" : ""

      if args[:'data-target'].present?
        options[:'data-target'] = args[:'data-target']
      end
      if args[:'data-tippy'].present?
        options[:'data-tippy'] = args[:'data-tippy']
      end
      if args[:title].present?
        options[:title] = args[:title]
      end

      # Create the path to the svgs directory
      file_path = "#{Avo::Engine.root}/app/assets/svgs/#{file_name}"
      file_path = "#{file_path}.svg" unless file_path.end_with? ".svg"

      # Create a cache hash
      hash = Digest::MD5.hexdigest "#{file_path.underscore}_#{options}"

      svg_content = Avo::App.cache_store.fetch "svg_file_#{hash}", expires_in: 1.week, cache_nils: false do
        if File.exist?(file_path)
          file = File.read(file_path)

          # parse svg
          doc = Nokogiri::HTML::DocumentFragment.parse file
          svg = doc.at_css "svg"

          # attach options
          options.each do |attr, value|
            svg[attr.to_s] = value
          end

          # cast to html
          doc.to_html.html_safe
        end
      end

      return "(not found)" if svg_content.to_s.blank?

      svg_content
    end

    def input_classes(extra_classes = "", has_error: false)
      classes = "appearance-none inline-flex bg-gray-100 disabled:cursor-not-allowed text-gray-600 disabled:opacity-50 rounded py-2 px-3 leading-tight border focus:border-gray-600 focus-visible:ring-0 focus:text-gray-700"

      classes += if has_error
        " border-red-600"
      else
        " border-gray-200"
      end

      classes += " #{extra_classes}"

      classes
    end

    def get_model_class(model)
      if model.instance_of?(Class)
        model
      else
        model.class
      end
    end
  end
end
