module Avocado
  module Fields
    module Element
      attr_accessor :show_on_index
      attr_accessor :show_on_show
      attr_accessor :show_on_create
      attr_accessor :show_on_edit

      def initialize(id, **args, &block)
        @show_on_index = @show_on_index.nil? ? true : @show_on_index
        @show_on_show = @show_on_show.nil? ? true : @show_on_show
        @show_on_create = @show_on_create.nil? ? true : @show_on_create
        @show_on_edit = @show_on_edit.nil? ? true : @show_on_edit
      end

      def show_on(*where)
        normalize_views(where).flatten.each do |view|
          show_on_view view
        end
      end

      def hide_on(*where)
        normalize_views(where).flatten.each do |view|
          hide_on_view view
        end
      end

      def only_on(*where)
        hide_on_all
        normalize_views(where).flatten.each do |view|
          show_on_view view
        end
      end

      def except_on(*where)
        show_on_all
        normalize_views(where).flatten.each do |view|
          show_on_view view
        end
      end

      private
        def show_on_view(view)
          self.send("show_on_#{view.to_s}=", true)
        end

        def hide_on_view(view)
          self.send("show_on_#{view.to_s}=", false)
        end

        def only_on_view(view)
          hide_on_all
          show_on_view view
        end

        def except_on_view(view)
          show_on_all
          hide_on_view view
        end

        def show_on_all
          @show_on_index = true
          @show_on_show = true
          @show_on_edit = true
          @show_on_create = true
        end

        def hide_on_all
          @show_on_index = false
          @show_on_show = false
          @show_on_edit = false
          @show_on_create = false
        end

        def normalize_views(*views_and_groups)
          forms = views_and_groups.flatten! & [:forms]

          if forms.present?
            views_and_groups = views_and_groups - forms
            views_and_groups = views_and_groups + [:create, :edit]
          end

          views_and_groups.flatten.uniq
        end
    end
  end
end
