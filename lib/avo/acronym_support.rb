# frozen_string_literal: true

module Avo
  # Handles host-app acronym inflections (e.g. `inflect.acronym "URL"`)
  module AcronymSupport
    module_function

    def apply!
      return unless defined?(Rails)

      require_relative "../../app/helpers/avo/url_helpers"

      if const_defined?(:UrlHelpers, false) && !const_defined?(:URLHelpers, false)
        const_set(:URLHelpers, const_get(:UrlHelpers))
      elsif const_defined?(:URLHelpers, false) && !const_defined?(:UrlHelpers, false)
        const_set(:UrlHelpers, const_get(:URLHelpers))
      end
    end
  end
end
