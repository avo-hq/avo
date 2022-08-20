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

    # I takes a filename or a path and tries to find the asset in this order:
    # - file inside the parent app's `app/assets/svgs` path
    # - full path in the parent app
    # - file inside the Avo's app/assets/svgs path
    # - full path in Avo's assets
    def svg(file_name, **args)
      return if file_name.nil?

      file_name = "#{file_name}.svg" unless file_name.end_with? ".svg"

      paths = [
        Rails.root.join("app", "assets", "svgs", file_name).to_s,
        Rails.root.join(file_name).to_s,
        Avo::Engine.root.join("app", "assets", "svgs", file_name).to_s,
        Avo::Engine.root.join(file_name).to_s,
      ]

      path = paths.find do |path|
        File.exist? path
      end

      return if path.nil?

      inline_svg_tag path, **args
    end

    def input_classes(extra_classes = "", has_error: false)
      classes = "appearance-none inline-flex bg-gray-25 disabled:cursor-not-allowed text-gray-600 disabled:opacity-50 rounded py-2 px-3 leading-tight border focus:border-gray-600 focus-visible:ring-0 focus:text-gray-700"

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

    def root_path_without_url
      Avo::App.root_path.to_s.delete_prefix(request.base_url.to_s).delete_suffix "/"
    rescue
      Avo.configuration.root_path
    end
  end
end
