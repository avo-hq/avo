# frozen_string_literal: true

class Avo::Index::ResourceTableComponent < ViewComponent::Base
  include Avo::ApplicationHelper
  attr_reader :pagy, :query

  def initialize(resources: nil, resource: nil, reflection: nil, parent_model: nil, parent_resource: nil, pagy: nil, query: nil)
    @resources = resources
    @resource = resource
    @reflection = reflection
    @parent_model = parent_model
    @parent_resource = parent_resource
    @pagy = pagy
    @query = query
  end

  def encrypted_query
    return if query.nil?

    Avo::Services::EncryptionService.encrypt(
      message: message_to_encrypt,
      purpose: :select_all
    )
  end

  def message_to_encrypt
    if query.respond_to? :all
      if query.all.respond_to? :to_sql
        query.all.to_sql
      else
        query.all
      end
    else
      query
    end
  end
end
