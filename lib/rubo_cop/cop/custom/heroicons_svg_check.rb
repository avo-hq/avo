require "rubocop"

module RuboCop
  module Cop
    module Custom
      class HeroiconsSvgCheck < RuboCop::Cop::Base
        MSG = "SVG declaration does not adhere to naming convention".freeze

        def on_send(node)
          return unless node.method_name == :svg
          return unless node.arguments[0]

          svg_arg = node.arguments[0].source
          return if svg_arg.match?(/\A['"](?:avo|heroicons)/)

          add_offense(node, message: MSG)
        end
      end
    end
  end
end
