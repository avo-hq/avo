module Generators
  module Avo
    module Concerns
      module OverrideController
        extend ActiveSupport::Concern

        included do
          class_option "--force",
            desc: "Skip override validation.",
            type: :string,
            required: false
        end

        def override_controller?
          return false if options[:force].present?
          return false unless controller_name.in? controllers_list

          say("Avo uses #{controller_class} internally, overriding it will cause malfunctions.", :red)
          say("Use --force if you really want to override the \033[1m#{controller_class}.", :yellow)

          true
        end

        def controllers_list
          Dir["app/controllers/avo/*.rb"].map { |file_path| File.basename(file_path, ".rb") }
        end
      end
    end
  end
end
