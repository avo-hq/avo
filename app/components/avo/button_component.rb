# frozen_string_literal: true

# A button/link can have the following settings:
# style: primary/secondary/ternary
# size: :sm, :md, :lg
class Avo::ButtonComponent < ViewComponent::Base
  def initialize(path = nil, size: :md, style: :secondary, icon: nil, icon_class: "", is_link: false, **args)
    # Main settings
    @size = size
    @style = style

    # Other things that appear in the button
    @path = path
    @icon = icon
    @icon_class = icon_class

    # Other settings
    @class = args[:class]
    @is_link = is_link
    @args = args || {}
  end

  def args
    if @args[:spinner]
      @args[:"data-controller"] = "loading-button"
    end

    @args[:class] = classes

    @args
  end

  def classes
    button_classes
  end


  def button_classes
    classes = "inline-flex flex-grow-0 items-center text-sm font-semibold leading-6 fill-current whitespace-nowrap transition duration-100 rounded transform transition duration-100 active:translate-x-px active:translate-y-px cursor-pointer disabled:cursor-not-allowed border #{@class}"

    classes += " space-x-1" if content.present? && @icon.present?

    classes += case @style
    when :primary
      " bg-blue-500 text-white border-blue-500 disabled:bg-blue-600"
    when :secondary
      " bg-white text-blue-500 border-blue-500"
    when :ternary
      " bg-white text-gray-500 border-gray-300"
    else
      ""
    end

    classes += " px-4" # Same horizontal padding on all sizes
    classes += case @size.to_sym
    when :sm
      " py-1"
    when :md
      " py-2"
    when :lg
      " py-3"
    else
      ""
    end

    classes
  end

  def is_link?
    @is_link
  end

  def the_content
    result = ""
    icon_classes = @icon_class

    case @size
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
    else
      ""
    end

    # icon_classes += content.present? ? " mr-1" : ""

    result += helpers.svg(@icon, class: icon_classes) if @icon.present?
    result += "<span>#{content}</span>" if content.present?

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
      the_content
    end
  end

  def output_button
    button_tag **args do
      the_content
    end
  end
end
