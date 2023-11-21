module Avo
  module Concerns
    module VisibleInDifferentViews
      attr_accessor :show_on_index
      attr_accessor :show_on_show
      attr_accessor :show_on_new
      attr_accessor :show_on_edit
      attr_accessor :show_on_preview

      def post_initialize
        initialize_views
      end

      def initialize_views
        # Set defaults
        @show_on_index = @show_on_index.nil? ? true : @show_on_index
        @show_on_show = @show_on_show.nil? ? true : @show_on_show
        @show_on_new = @show_on_new.nil? ? true : @show_on_new
        @show_on_edit = @show_on_edit.nil? ? true : @show_on_edit
        @show_on_preview = @show_on_preview.nil? ? false : @show_on_preview

        if @args.present?
          # Execute options
          show_on @args[:show_on] if @args[:show_on].present?
          hide_on @args[:hide_on] if @args[:hide_on].present?
          only_on @args[:only_on] if @args[:only_on].present?
          except_on @args[:except_on] if @args[:except_on].present?
        end
      end

      # Validates if the field is visible on certain view
      def visible_in_view?(view:)
        raise "No view specified on visibility check." if view.blank?

        send "show_on_#{view}"
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
          hide_on_view view
        end
      end

      # When submitting the form on creation, the new page will be create but we don't have a visibility marker for create so we'll default to new
      def show_on_create
        show_on_new
      end

      # When submitting the form on update, the new page will be create but we don't have a visibility marker for update so we'll default to edit
      def show_on_update
        show_on_edit
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
        @show_on_preview = true
      end

      def hide_on_all
        @show_on_index = false
        @show_on_show = false
        @show_on_edit = false
        @show_on_new = false
        @show_on_preview = false
      end

      def normalize_views(*views_and_groups)
        forms = views_and_groups.flatten! & [:forms]
        display = views_and_groups & [:display]

        if forms.present?
          views_and_groups -= forms
          views_and_groups += [:new, :edit]
        end

        if display.present?
          views_and_groups -= display
          views_and_groups += [:index, :show]
        end

        views_and_groups.flatten.uniq
      end
    end
  end
end
