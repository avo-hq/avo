module Avocado
  class App
    def init
      @tools = ''
    end

    class << self

      def render_navigation
        'rendered_navigation'
      end
    end
  end
end
