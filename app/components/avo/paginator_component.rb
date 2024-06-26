# frozen_string_literal: true

class Avo::PaginatorComponent < Avo::BaseComponent
  prop :resource, _Nilable(_Any), reader: :public
  prop :parent_record, _Nilable(_Any), reader: :public
  prop :pagy, _Nilable(Pagy), reader: :public
  prop :turbo_frame, _Nilable(String), reader: :public
  prop :index_params, _Nilable(Hash), reader: :public
  prop :discreet_pagination, _Boolean, default: false, reader: :public do |value|
    !!value
  end

  def change_items_per_page_url(option)
    if parent_record.present?
      helpers.related_resources_path(parent_record, parent_record, per_page: option, keep_query_params: true, page: 1)
    else
      helpers.resources_path(resource: resource, per_page: option, keep_query_params: true, page: 1)
    end
  end

  def render?
    return false if discreet_pagination && pagy.pages <= 1

    @pagy.items > 0
  end

  def per_page_options
    @per_page_options ||= begin
      options = [*Avo.configuration.per_page_steps, Avo.configuration.per_page.to_i, index_params[:per_page].to_i]

      if parent_record.present?
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
