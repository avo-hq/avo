# frozen_string_literal: true

class PaginatorComponentPreview < Lookbook::Preview
  include Avo::ApplicationHelper
  include ::ApplicationHelper
  # @!group Examples

  # Default state — middle page, both prev and next enabled
  def default
    render Avo::PaginatorComponent.new(**component_args(page: 3))
  end

  # First page — previous button disabled
  def first_page
    render Avo::PaginatorComponent.new(**component_args(page: 1))
  end

  # Last page — next button disabled
  def last_page
    render Avo::PaginatorComponent.new(**component_args(page: 5))
  end

  # @!endgroup

  private

  def component_args(page:)
    per_page = 24
    count = 110

    pagy_opts = {count: count, page: page}
    pagy_opts[(::Gem::Version.new("9.0") <= ::Pagy::VERSION) ? :limit : :items] = per_page
    pagy = Pagy.new(**pagy_opts)

    resource = Avo::Resources::User.new

    {
      resource: resource,
      pagy: pagy,
      turbo_frame: nil,
      index_params: {per_page: per_page},
      discreet_pagination: false,
      parent_record: nil,
      parent_resource: nil
    }
  end
end
