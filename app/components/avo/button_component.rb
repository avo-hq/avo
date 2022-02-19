# frozen_string_literal: true

class Avo::ButtonComponent < ViewComponent::Base
  def initialize(size: :md, type: :secondary, icon: nil, is_link: false, href: nil, **args)
    @size = size
    @type = type
    @icon = icon
    @href = href
    @is_link = is_link
    @args = args || {}
  end

  def args
    if @args[:spinner]
      args[:"data-controller"] = "loading-button"
    end

    @args
  end

  def label
    'lalb'
  end

  def is_link?
    @is_link
  end

  def the_content
    result = ""

    result += @icon if @icon.present?
    result += content if content.present?

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
    if content.empty?
      link_to label, @href, **args
    else
      link_to @href, **args do
        content
      end
    end
  end

  def output_button
    if content.empty?
      button_tag label, **args
    else
      button_tag **args do
        the_content
      end
    end
  end








  # args[:class] = button_classes(args[:class], color: args[:color], variant: args[:variant], size: args[:size])
  # if args[:spinner]
  #   args[:"data-controller"] = "loading-button"
  # end

  # locals = {
  #   label: label,
  #   args: args
  # }

  # if block
  #   render layout: "avo/partials/a_button", locals: locals do
  #     capture(&block)
  #   end
  # else
  #   render partial: "avo/partials/a_button", locals: locals
  # end




  # <% if is_link? %>
  #   <% if content.empty? %>
  #     <%= link_to label, @href, **args %>
  #   <% else %>
  #     <%= link_to @href, **args do %>
  #     <% end %>
  #   <% end %>
  # <% else %>
  #   <% if content.empty? %>
  #     <%= button_tag label, **args %>
  #   <% else %>
  #     <%= button_tag **args do %>
  #       <%= the_content %>
  #     <% end %>
  #   <% end %>
  # <% end %>

end
