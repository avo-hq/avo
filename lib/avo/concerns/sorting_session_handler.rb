module Avo
  module Concerns
    module SortingSessionHandler
      # Puts the remembered sort into params, where the index query and the table header read it from, so a
      # plain visit sorts the same way a sort link would.
      def restore_sorting
        return unless Avo.configuration.persist?(:sorting)

        # A sort link built right after a reset still carries the reset flag, so the sort wins over the flag.
        if params[:sort_by].present?
          session[sorting_session_key] = {"sort_by" => params[:sort_by], "sort_direction" => params[:sort_direction]}
        elsif params[:reset_sorting]
          session.delete(sorting_session_key)
        elsif (sorting = session[sorting_session_key])
          # A field the resource dropped or stopped sorting by would otherwise come back on every visit, with no
          # header left to reset it from. Any declaration of the id counts: a resource may declare the same id
          # once per view, with only the index one sortable.
          if @resource.get_field_definitions.any? { |f| f.id.to_s == sorting["sort_by"].to_s && f.sortable }
            params[:sort_by], params[:sort_direction] = sorting.values_at("sort_by", "sort_direction")
          else
            session.delete(sorting_session_key)
          end
        end
      end

      # One sort per table, so a has_many table remembers its own, apart from the related resource's index.
      def sorting_session_key
        @sorting_session_key ||= "/sorting/" << %w[
          controller resource_name related_name action
        ].map { |key| params[key] }.compact.join("/")
      end
    end
  end
end
