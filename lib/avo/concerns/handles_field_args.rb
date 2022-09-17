module Avo
  module Concerns
    module HandlesFieldArgs
      extend ActiveSupport::Concern

      private

      # Add an instance variable from args
      # That may be a string, boolean, or array
      # Each args should also have a default value
      def add_prop_from_args(args = {}, name: nil, type: :string, default: nil)
        value = default

        if type == :boolean
          value = args[name.to_sym] == true
        else
          value = args[name.to_sym] unless args.dig(name.to_sym).nil?
        end

        instance_variable_set(:"@#{name}", value)
      end

      def add_boolean_prop(args, name, default = false)
        add_prop_from_args args, name: name, default: default, type: :boolean
      end

      def add_array_prop(args, name, default = [])
        add_prop_from_args args, name: name, default: default, type: :array
      end

      def add_string_prop(args, name, default = nil)
        add_prop_from_args args, name: name, default: default, type: :string
      end
    end
  end
end
