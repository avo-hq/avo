# frozen_string_literal: true

class Avo::ButtonComponent < Avo::BaseComponent
  prop :path, kind: :positional
  prop :size, default: :md
  prop :style, default: :outline
  prop :color, default: :gray
  prop :icon do |value|
    value&.to_sym
  end
  prop :icon_class, default: ""
  prop :is_link, default: false
  prop :rounded, default: true
  prop :compact, default: false
  prop :aria, default: {}.freeze
  prop :args, kind: :**, default: {}.freeze
  prop :class

  def args
    if @args[:loading]
      @args[:"data-controller"] = "loading-button"
      @args[:"data-action"] = "click->loading-button#attemptSubmit"
    end

    @args[:class] = button_classes
    @args[:aria] = @aria

    @args
  end

  def button_classes
    classes = "button-component inline-flex flex-grow-0 items-center font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 transform transition duration-100 cursor-pointer disabled:cursor-not-allowed disabled:opacity-65 data-[disabled='true']:opacity-65 justify-center #{@class}"

    # For non-icon-styled buttons we should not add borders.
    classes += " border active:outline active:outline-1" unless is_icon?

    classes += " rounded" if @rounded.present?
    classes += style_classes
    classes += horizontal_padding_classes
    classes += vertical_padding_classes
    classes += text_size_classes

    classes
  end

  def is_link?
    @is_link
  end

  def is_icon?
    @style == :icon
  end

  def is_not_icon?
    !is_icon?
  end

  def full_content
    result = ""
    # space out the icon from the text if text is present
    # add the icon height
    icon_classes = class_names(@icon_class, "pointer-events-none", icon_size_classes, "mr-1": content.present? && is_not_icon?)

    # Add the icon
    result += helpers.svg(@icon, class: icon_classes) if @icon.present?

    if is_not_icon? && content.present?
      result += content
    end

    result.html_safe
  end

  def call
    if is_link?
      output_link
    else
      output_button
    end
  end

  def output_link
    link_to @path, **args do
      full_content
    end
  end

  def output_button
    if args.dig(:method).present? || args.dig(:data, :turbo_method).present?
      button_to args[:url], **args do
        full_content
      end
    else
      button_tag(**args) do
        full_content
      end
    end
  end

  private

  def vertical_padding_classes
    return " py-0" if is_icon?

    case @size.to_sym
    when :xs
      " py-0"
    when :sm
      " py-1"
    when :md
      " py-1.5"
    when :lg
      " py-2"
    when :xl
      " py-3"
    else
      ""
    end
  end

  def horizontal_padding_classes
    return " px-0" if is_icon?
    return " px-1" if @compact

    case @size.to_sym
    when :xs
      " px-2"
    when :sm
      " px-3"
    when :md
      " px-3"
    when :lg
      " px-5"
    when :xl
      " px-6"
    else
      "px-4"
    end
  end

  def text_size_classes
    case @size.to_sym
    when :xs
      " text-xs"
    else
      " text-sm"
    end
  end

  def style_classes
    case @style
    when :primary
      " bg-#{@color}-500 text-white border-#{@color}-500 hover:bg-#{@color}-600 hover:border-#{@color}-600 active:border-#{@color}-600 active:outline-#{@color}-600 active:bg-#{@color}-600"
    when :outline
      " bg-white text-#{@color}-500 border-#{@color}-500 hover:bg-#{@color}-100 active:bg-#{@color}-100 active:border-#{@color}-500 active:outline-#{@color}-500"
    when :text
      " text-#{@color}-500 active:outline-#{@color}-500 hover:bg-gray-100 border-transparent"
    when :icon
      " text-#{@color}-600"
    else
      ""
    end
  end

  def icon_size_classes
    icon_classes = ""
    return icon_classes if is_icon?

    case @size
    when :xs
      icon_classes += " h-4 my-1"
    when :sm
      icon_classes += " h-4 my-1"
    when :md
      icon_classes += " h-4 my-1"
    when :lg
      icon_classes += " h-5 my-0.5"
    when :xl
      icon_classes += " h-6"
    end

    icon_classes
  end
end
