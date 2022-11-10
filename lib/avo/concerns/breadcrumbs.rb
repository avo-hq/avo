module Avo
  module Concerns
    # This is a custom implementation of breadcrumbs largely based on breadcrumbs_on_rails gem
    # created by Simone Carletti (@weppos) and released on MIT license.
    #
    # https://github.com/weppos/breadcrumbs_on_rails
    #
    # The reason to use custom implementation is to
    #   * Avoid naming conflicts with other gems adding helpers like `breadcrumbs`
    #   * Reduce number of dependencies
    module Breadcrumbs
      extend ActiveSupport::Concern

      included do |base|
        helper HelperMethods
        extend ClassMethods
        helper_method :add_breadcrumb, :avo_breadcrumbs
      end

      Crumb = Struct.new(:name, :path)

      class Builder
        DEFAULT_SEPARATOR = " &raquo; ".freeze

        attr_reader :context, :options

        def initialize(context, options)
          @context = context
          @options = options
        end

        def render
          separator = options.fetch(:separator, DEFAULT_SEPARATOR)
          breadcrumbs.map(&method(:render_element)).join(separator)
        end

        private

        def breadcrumbs
          context.avo_breadcrumbs
        end

        def render_element(element)
          content = element.path.nil? ? compute_name(element) : context.link_to_unless_current(compute_name(element), compute_path(element))
          options[:tag] ? context.content_tag(options[:tag], content) : ERB::Util.h(content)
        end

        def compute_name(element)
          case name = element.name
          when Symbol
            context.send(name)
          when Proc
            name.call(context)
          else
            name.to_s
          end
        end

        def compute_path(element)
          case path = element.path
          when Symbol
            context.send(path)
          when Proc
            path.call(context)
          else
            context.url_for(path)
          end
        end
      end

      module ClassMethods
        def add_breadcrumb(name, path = nil)
          before_action(filter_options) do |controller|
            controller.send(:add_breadcrumb, name, path)
          end
        end
      end

      def add_breadcrumb(name, path = nil)
        avo_breadcrumbs << Crumb.new(name, path)
      end

      def avo_breadcrumbs
        @avo_breadcrumbs ||= []
      end

      module HelperMethods
        def render_avo_breadcrumbs(options = {}, &block)
          builder = Builder.new(self, options)
          content = builder.render.html_safe
          block_given? ? capture(content, &block) : content
        end
      end
    end
  end
end
