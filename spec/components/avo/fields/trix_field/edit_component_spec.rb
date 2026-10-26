require "rails_helper"

RSpec.describe Avo::Fields::TrixField::EditComponent, type: :component do
  around { |example| with_controller_class(Avo::ApplicationController) { example.run } }

  let(:fish_form) { ActionView::Helpers::FormBuilder.new(:fish, Fish.new, vc_test_controller.view_context, {}) }

  def input_id(form:, resource_class:)
    resource = resource_class.new(record: form.object, view: :edit)
    field = Avo::Fields::TrixField.new(:body).hydrate(record: form.object, resource:, view: :edit)

    render_inline(described_class.new(field:, form:, resource:))

    page.find("textarea", visible: false)["id"]
  end

  def nested_review_input_id(child_index)
    id = nil
    fish_form.fields_for(:reviews, Review.new, child_index:) do |nested_form|
      id = input_id(form: nested_form, resource_class: Avo::Resources::Review)
    end
    id
  end

  it "keeps the resource-scoped id on a top-level form" do
    post_form = ActionView::Helpers::FormBuilder.new(:post, Post.new, vc_test_controller.view_context, {})

    expect(input_id(form: post_form, resource_class: Avo::Resources::Post)).to eq "trix_post_body"
  end

  # Nested forms (avo-nested) render one editor per record, all for the same resource.
  it "gives every nested record its own input id" do
    expect(nested_review_input_id(0)).not_to eq nested_review_input_id(1)
  end

  # The new-record template is cloned by stimulus-rails-nested-form, which only
  # replaces the NEW_RECORD placeholder, so the id must carry it.
  it "carries the NEW_RECORD placeholder in the nested template id" do
    expect(nested_review_input_id("NEW_RECORD")).to include "NEW_RECORD"
  end
end
