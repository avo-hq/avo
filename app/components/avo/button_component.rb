# frozen_string_literal: true

# A button/link can have the following settings:
# style: primary/secondary/ternary
# size: :xs :sm, :md, :lg
class Avo::ButtonComponent < ViewComponent::Base
  def initialize(path = nil, size: :md, style: :outline, color: :gray, icon: nil, icon_class: "", is_link: false, rounded: true, compact: false, **args)
    # Main settings
    @size = size
    @style = style
    @color = color

    # Other things that appear in the button
    @path = path
    @icon = icon
    @icon_class = icon_class
    @rounded = rounded
    @compact = compact

    # Other settings
    @class = args[:class]
    @is_link = is_link
    @args = args || {}
  end

  def args
    if @args[:loading]
      @args[:"data-controller"] = "loading-button"

      if @args[:confirm]
        @args[:"data-avo-confirm"] = @args.delete(:confirm)
      end
    end

    @args[:class] = button_classes

    @args
  end

  def button_classes
    classes = "button-component inline-flex flex-grow-0 items-center text-sm font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 transform transition duration-100 cursor-pointer disabled:cursor-not-allowed disabled:opacity-70 border justify-center active:outline active:outline-1 #{@class}"

    classes += " rounded" if @rounded.present?

    classes += style_classes

    classes += @compact ? " px-1" : " px-4" # Same horizontal padding on all sizes
    classes += spacing_classes

    classes
  end

  def is_link?
    @is_link
  end

  def full_content
    result = ""
    icon_classes = @icon_class
    icon_classes += full_content_icon_classes

    result += helpers.svg(@icon, class: icon_classes) if @icon.present?
    result += "<span class='w-0 m-0'>&nbsp;</span>"
    if content.present?
      result += "<span>#{content}</span>"
    end

    result.html_safe
  end

  def output
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
    if @args[:method].present?
      button_to @args[:url], **args do
        full_content
      end
    else
      button_tag(**args) do
        full_content
      end
    end
  end

  private

  def spacing_classes
    case @size.to_sym
    when :xs
      " py-0"
    when :sm
      " py-1"
    when :md
      " py-2"
    when :lg
      " py-3"
    else
      ""
    end
  end

  def style_classes
    case @style
    when :primary
      " bg-primary-500 text-white border-primary-500 hover:bg-primary-600 hover:border-primary-600 active:border-primary-700 active:outline-primary-700 active:bg-primary-600"
    when :outline
      " bg-white text-#{@color}-500 border-#{@color}-500 hover:bg-#{@color}-100 active:bg-#{@color}-100 active:border-#{@color}-500 active:outline-#{@color}-500"
    else
      ""
    end
  end

  def full_content_icon_classes
    icon_classes = ""

    case @size
    when :xs
      icon_classes += " h-4"
      # When icon is solo we need to add an offset
      icon_classes += " my-1" if content.blank?
    when :sm
      icon_classes += " h-4"
      # When icon is solo we need to add an offset
      icon_classes += " my-1" if content.blank?
    when :md
      icon_classes += " h-5"
      # When icon is solo we need to add an offset
      icon_classes += " my-0.5" if content.blank?
    when :lg
      icon_classes += " h-6"
    end

    icon_classes
  end
end
