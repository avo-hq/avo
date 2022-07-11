require_relative "named_base_generator"

module Generators
  module Avo
    class FilterGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      class_option :multiple_select, type: :boolean
      class_option :select, type: :boolean
      class_option :text, type: :boolean

      namespace "avo:filter"

      def create_resource_file
        type = "boolean"

        type = "multiple_select" if options[:multiple_select]
        type = "select" if options[:select]
        type = "text" if options[:text]

        template "filters/#{type}_filter.tt", "app/avo/filters/#{singular_name}.rb"
      end
    end
  end
end
