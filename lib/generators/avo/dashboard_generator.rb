require_relative "named_base_generator"

module Generators
  module Avo
    class DashboardGenerator < NamedBaseGenerator
      source_root File.expand_path("templates", __dir__)

      namespace "avo:dashboard"
      desc "Add an Avo dashboard to your project."

      def handle
        template "dashboards/dashboard.tt", "app/avo/dashboards/#{name.underscore}.rb"
      end
    end
  end
end
