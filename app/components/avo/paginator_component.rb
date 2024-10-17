# frozen_string_literal: true

class Avo::PaginatorComponent < Avo::BaseComponent
  prop :resource
  prop :parent_record
  prop :pagy
  prop :turbo_frame do |frame|
    frame.present? ? CGI.escapeHTML(frame) : :_top
  end
  prop :index_params
  prop :discreet_pagination

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

  def anchor_string
    if @parent_record.present?
      "data-turbo-frame=\"#{@turbo_frame}\""
    else
      "data-turbo-frame=\"#{@turbo_frame}\", data-turbo-action=\"advance\""
    end
  end
end
