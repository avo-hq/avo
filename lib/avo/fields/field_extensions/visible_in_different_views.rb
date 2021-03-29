module Avo
  module Fields
    module FieldExtensions
      module VisibleInDifferentViews
        attr_accessor :show_on_index
        attr_accessor :show_on_show
        attr_accessor :show_on_new
        attr_accessor :show_on_edit

        def initialize(id, **args, &block)
          @show_on_index = @show_on_index.nil? ? true : @show_on_index
          @show_on_show = @show_on_show.nil? ? true : @show_on_show
          @show_on_new = @show_on_new.nil? ? true : @show_on_new
          @show_on_edit = @show_on_edit.nil? ? true : @show_on_edit
        end

        def show_on(*where)
          return show_on_all if where.include? :all

          normalize_views(where).flatten.each do |view|
            show_on_view view
          end
        end

        def hide_on(*where)
          return hide_on_all if where.include? :all

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
          send("show_on_#{view}=", true)
        end

        def hide_on_view(view)
          send("show_on_#{view}=", false)
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
          @show_on_new = true
        end

        def hide_on_all
          @show_on_index = false
          @show_on_show = false
          @show_on_edit = false
          @show_on_new = false
        end

        def normalize_views(*views_and_groups)
          forms = views_and_groups.flatten! & [:forms]

          if forms.present?
            views_and_groups -= forms
            views_and_groups += [:new, :edit]
          end

          views_and_groups.flatten.uniq
        end
      end
    end
  end
end
