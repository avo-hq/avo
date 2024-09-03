# frozen_string_literal: true

class Avo::PaginatorComponent < Avo::BaseComponent
  prop :resource, _Nilable(Avo::BaseResource)
  prop :parent_record, _Nilable(_Any)
  prop :pagy, _Nilable(Pagy)
  prop :turbo_frame, _Nilable(_Union(String, Symbol)) do |frame|
    frame.present? ? CGI.escapeHTML(frame) : :_top
  end
  prop :index_params, _Nilable(Hash)
  prop :discreet_pagination, _Nilable(_Boolean)

  def change_items_per_page_url(option)
    if @parent_record.present?
      helpers.related_resources_path(@parent_record, @parent_record, per_page: option, keep_query_params: true, page: 1)
    else
      helpers.resources_path(resource: @resource, per_page: option, keep_query_params: true, page: 1)
    end
  end

  def render?
    return false if @discreet_pagination && @pagy.pages <= 1

    if ::Pagy::VERSION >= ::Gem::Version.new("9.0")
      @pagy.limit > 0
    else
      @pagy.items > 0
    end
  end

  def per_page_options
    @per_page_options ||= begin
      options = [*Avo.configuration.per_page_steps, Avo.configuration.per_page.to_i, @index_params[:per_page].to_i]

      if @parent_record.present?
        options.prepend Avo.configuration.via_per_page
      end

      options.sort.uniq
    end
  end

  def pagy_major_version
    return nil unless defined?(Pagy::VERSION)
    version = Pagy::VERSION&.split(".")&.first&.to_i

    return "8-or-more" if version >= 8

    version
  end
end
