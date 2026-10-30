module Avo
  module Concerns
    module SortingSessionHandler
      # Puts the remembered sort into params, where the index query and the table header read it from, so a
      # plain visit sorts the same way a sort link would.
      def restore_sorting
        return unless Avo.configuration.persist?(:sorting)

        if params[:reset_sorting]
          session.delete(sorting_session_key)
        elsif params[:sort_by]
          session[sorting_session_key] = {"sort_by" => params[:sort_by], "sort_direction" => params[:sort_direction]}
        elsif (sorting = session[sorting_session_key])
          params[:sort_by], params[:sort_direction] = sorting.values_at("sort_by", "sort_direction")
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
