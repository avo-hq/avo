# Allows to check the the view type by using `view.index?` or `view.edit?` etc...
# It also allows to check if the view is a form or a display view by using `view.form?` or `view.display?`
module Avo
  class ViewInquirer < ActiveSupport::StringInquirer
    DISPLAY_VIEWS = %w[index show].freeze unless defined? DISPLAY_VIEWS
    FORM_VIEWS = %w[new edit].freeze unless defined? FORM_VIEWS

    def initialize(view)
      super(view.to_s)

      @display = in? DISPLAY_VIEWS
      @form = in? FORM_VIEWS
    end

    def display?
      @display
    end

    def form?
      @form
    end

    # To avoid breaking changes we allow the comparison with symbols
    def ==(other)
      if other.is_a? Symbol
        to_sym == other
      else
        super(other)
      end
    end

    def in?(another_object)
      super another_object.map(&:to_s)
    end
  end
end
