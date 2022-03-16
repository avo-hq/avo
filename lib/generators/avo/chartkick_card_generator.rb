require "rails/generators"

module Generators
  module Avo
    class ChartkickCardGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      namespace "avo:card:chartkick"
      desc "Add a chartkick card for your Avo dashboard."

      def handle
        template "cards/chartkick_card_sample.tt", "app/avo/cards/#{name.underscore}.rb"
      end
    end
  end
end
