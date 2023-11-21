module Avo
  module Concerns
    module Hydration
      extend ActiveSupport::Concern

      def hydrate(**args)
        args.each do |key, value|
          value = Avo::ViewInquirer.new value if key == :view

          send("#{key}=", value) if respond_to?("#{key}=")
        end

        self
      end
    end
  end
end
