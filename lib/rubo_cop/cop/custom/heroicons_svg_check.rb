require "rubocop"

module RuboCop
  module Cop
    module Custom
      class HeroiconsSvgCheck < RuboCop::Cop::Base
        MSG = "SVG declaration does not adhere to naming convention".freeze

        def on_send(node)
          return unless node.method_name == :svg
          return if heroicons?(node)

          add_offense(node, message: MSG)
        end

        private

        def heroicons?(node)
          svg_arg = node.arguments[0].source
          svg_arg.match?(/\A['"](edit|three-dots|some_icon)['"]\z/)
        end
      end
    end
  end
end
