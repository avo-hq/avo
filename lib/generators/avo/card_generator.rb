require_relative "named_base_generator"

module Generators
  module Avo
    class Card < NamedBaseGenerator
      namespace "avo:card"
      source_root File.expand_path("templates", __dir__)
      class_option :type, type: :string

      def handle
        raise "Invalid card type '#{options[:type]}'" unless card_types.include? options[:type]

        template "cards/#{options[:type]}_card_sample.tt", "app/avo/cards/#{name.underscore}.rb"

        if options[:type].to_sym == :partial
          template "cards/partial_card_partial.tt", "app/views/avo/cards/_#{name.underscore}.html.erb"
        end
      end

      private

      def card_types
        %w[metric chartkick partial]
      end
    end
  end
end
