require "rails/generators"

module Generators
  module Avo
    class MetricCardGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      namespace "avo:card:metric"
      desc "Add a metric card for your Avo dashboard."

      def handle
        template "cards/metric_card_sample.tt", "app/avo/cards/#{name.underscore}.rb"
      end
    end
  end
end
