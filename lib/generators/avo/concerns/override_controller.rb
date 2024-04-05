module Generators
  module Avo
    module Concerns
      module OverrideController
        extend ActiveSupport::Concern

        def override_controller?
          return false unless controller_name.in? controllers_list

          say("Avo uses #{controller_class} internally, overriding it would cause malfunctions.", :red)
          true
        end

        def controllers_list
          Dir["app/controllers/avo/*.rb"].map { |file_path| File.basename(file_path, ".rb") }
        end
      end
    end
  end
end
