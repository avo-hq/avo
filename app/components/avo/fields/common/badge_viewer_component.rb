# frozen_string_literal: true

class Avo::Fields::Common::BadgeViewerComponent < ViewComponent::Base
  def initialize(value:, options:)
    @value = value
    @options = options
    @backgrounds = {
      info: "bg-blue-500",
      success: "bg-green-500",
      danger: "bg-red-500",
      warning: "bg-yellow-500",
      neutral: "bg-gray-500"
    }
  end

  def classes
    background = :info

    @options.invert.each do |values, type|
      if [values].flatten.map { |value| value }.include? @value
        background = type.to_sym
        next
      end
    end

    classes = "whitespace-nowrap rounded-md uppercase px-2 py-1 text-xs font-bold block text-center truncate "

    classes += "#{@backgrounds[background]} text-white" if @backgrounds[background].present?

    classes
  end
end
