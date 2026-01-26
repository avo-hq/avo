# frozen_string_literal: true

# A button/link can have the following settings:
# style: primary/outline/text
# size: :sm, :md, :lg
# color: :gray, :red, :green, :blue, or any other tailwind color
# icon: "heroicons/outline/paperclip" as specified in the docs (https://docs.avohq.io/3.0/icons.html)
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
    base_classes = [
      "button",
      "button--size-#{@size}",
      "button--style-#{@style}",
      @class,
      "button--color-#{@color}": @color.present?
    ]
    base_classes << "button--loading" if @args[:loading]

    class_names(*base_classes.compact)
  end

  def is_link?
    @is_link
  end

  def is_icon_style?
    @style == :icon
  end

  def is_not_icon_style?
    !is_icon_style?
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
      render_content
    end
  end

  def output_button
    if args.dig(:method).present? || args.dig(:data, :turbo_method).present?
      button_to args[:url], **args do
        render_content
      end
    else
      button_tag(**args) do
        render_content
      end
    end
  end

  private

  def render_content
    # if is_icon_style?
    #   helpers.svg(@icon, class: class_names("button__icon", @icon_class)) if @icon.present?
    # else
    # content_tag :span, class: "button__content" do
    concat helpers.svg(@icon, class: class_names("button__icon", @icon_class)) if @icon.present?
    concat content if content.present?
    # end
    # end
  end
end
