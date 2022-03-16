require "rails/generators"

module Generators
  module Avo
    class PartialCardGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      namespace "avo:card:partial"
      desc "Add a partial card for your Avo dashboard."

      def handle
        template "cards/partial_card_sample.tt", "app/avo/cards/#{name.underscore}.rb"
        template "cards/partial_card_partial.tt", "app/views/avo/cards/_#{name.underscore}.html.erb"
      end
    end
  end
end
