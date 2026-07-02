# frozen_string_literal: true

class Avo::PaginatorComponent < Avo::BaseComponent
  NUMBER_DELIMITER = "."

  prop :resource
  prop :parent_record
  prop :parent_resource
  prop :pagy
  prop :turbo_frame do |frame|
    frame.present? ? CGI.escapeHTML(frame) : :_top
  end
  prop :index_params
  prop :discreet_pagination

  def change_items_per_page_url(option)
    if @parent_record.present?
      helpers.related_resources_path(
        @parent_record,
        @parent_record,
        parent_resource: @parent_resource,
        per_page: option,
        keep_query_params: true,
        page: 1
      )
    else
      helpers.resources_path(resource: @resource, per_page: option, keep_query_params: true, page: 1)
    end
  end

  def render?
    return false if @discreet_pagination && @pagy.pages <= 1

    @pagy.limit > 0
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

  def current_per_page_label
    per_page_option_label(@index_params[:per_page])
  end

  def per_page_option_label(option)
    num = helpers.content_tag(:span, option, class: "pagination__per-page-option-num")
    "#{num} #{t("avo.per_page").downcase}".html_safe
  end

  def formatted_count
    formatted_number(@pagy.count)
  end

  def formatted_series_nav
    @pagy.series_nav(anchor_string: %(data-turbo-frame="#{@turbo_frame}"))
      .gsub(/>(\d{4,})</) { |match| match.sub($1, formatted_number($1)) }
      .html_safe
  end

  private

  def formatted_number(number)
    helpers.number_with_delimiter(number, delimiter: NUMBER_DELIMITER)
  end
end
