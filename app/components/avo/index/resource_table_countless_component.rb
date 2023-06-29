# frozen_string_literal: true

class Avo::Index::ResourceTableCountlessComponent < ViewComponent::Base
  include Avo::ApplicationHelper
  attr_reader :pagy_countless, :query

  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil, pagy_countless: nil, query: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
    @pagy_countless = pagy_countless
    @query = query
  end

  def encrypted_query
    return :select_all_disabled if query.nil? || !query.respond_to?(:all) || !query.all.respond_to?(:to_sql)

    Avo::Services::EncryptionService.encrypt(
      message: query.all.to_sql,
      purpose: :select_all
    )
  end
end
