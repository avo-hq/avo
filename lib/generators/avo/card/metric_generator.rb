require_relative "../named_base_generator"

module Generators
  module Avo
    module Card
      class MetricGenerator < Generators::Avo::NamedBaseGenerator
        source_root File.expand_path("../templates", __dir__)

        namespace "avo:card:metric"
        desc "Add a metric card for your Avo dashboard."

        def handle
          template "cards/metric_card_sample.tt", "app/avo/cards/#{name.underscore}.rb"
        end
      end
    end
  end
end
