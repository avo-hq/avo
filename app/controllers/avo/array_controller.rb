module Avo
  class ArrayController < BaseController

    def apply_pagination
      # Set `trim_extra` to false in associations so the first page has the `page=1` param assigned
      @pagy, @records = @resource.apply_pagination(index_params: @index_params, query: @resource.itemss)
    end



    # Sub-method called only by #pagy_countless: here for easy customization of variables by overriding
    def pagy_countless_get_vars(collection, vars)
      vars[:page] ||= params[vars[:page_param] || :page]
      # abort [collection.all, vars].inspect
      vars[:per_page] ||= params[vars[:per_page_param] || :per_page]
      vars
    end

    # Sub-method called only by #pagy_countless: here for easy customization of record-extraction by overriding
    # You may need to override this method for collections without offset|limit
    def pagy_countless_get_items(collection, pagy)
      # abort collection.inspect
      # abort pagy.inspect
      if pagy.vars[:per_page].present?
        collection.page(pagy.page).limit(pagy.vars[:per_page]).all.to_a # get the actual collection
      else
        # abort 1.inspect
        eager_loaded = collection.page(pagy.page).limit(pagy.items + 1).all.to_a # eager load items + 1
        pagy.finalize(eager_loaded.size)
        collection.page(pagy.page).limit(pagy.vars[:per_page]).all.to_a # get the actual collection
      end
    end

    def paginate_query
      if false
        pagy_countless(
          @query,
          items: @index_params[:per_page],
          link_extra: "data-turbo-frame=\"#{params[:turbo_frame]}\"",
          size: [],
          params: extra_pagy_params
        )
      else
        pagy_countless(
          @query,
          items: @index_params[:per_page],
          link_extra: "data-turbo-frame=\"#{params[:turbo_frame]}\"",
          size: [],
          params: extra_pagy_params
        )
      end
    end

    def perform_save_action!
      if @model&.id.present?
        @resource.client.update(@model.id, @model)
      else
        @resource.client.create(@model)
      end
    end

    def perform_destroy_action!
      @resource.client.delete(@model.id)
    end
  end
end
