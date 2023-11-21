require_relative "named_base_generator"

module Generators
  module Avo
    class FilterGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      class_option :type, type: :string, default: "boolean"

      namespace "avo:filter"

      def create_resource_file
        raise "Invalid filter type '#{options[:type]}'" unless filter_types.include? options[:type]

        template "filters/#{options[:type]}_filter.tt", "app/avo/filters/#{singular_name}.rb"
      end

      private

      def filter_types
        %w[boolean select text multiple_select]
      end
    end
  end
end
