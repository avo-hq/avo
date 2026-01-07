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
        helper_method :add_breadcrumb, :avo_breadcrumbs
      end

      Crumb = Data.define(:title, :path, :avatar, :initials, :icon) unless defined?(Crumb)

      class Builder
        extend PropInitializer::Properties
        prop :context, reader: :public
        prop :options, reader: :public

        def breadcrumbs = context.avo_breadcrumbs
      end

      def add_breadcrumb(title: nil, path: nil, avatar: nil, initials: nil, icon: nil)
        avo_breadcrumbs << Crumb.new(title:, path:, avatar:, initials:, icon:)
      end

      def avo_breadcrumbs
        @avo_breadcrumbs ||= []
      end
    end
  end
end
