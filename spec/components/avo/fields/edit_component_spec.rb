require "rails_helper"

RSpec.describe Avo::Fields::EditComponent, type: :component do
  around { |example| with_controller_class(Avo::ApplicationController) { example.run } }

  let(:post_form) { ActionView::Helpers::FormBuilder.new(:post, Post.new, vc_test_controller.view_context, {}) }

  def render_name_input(component_args: {}, **field_args)
    resource = Avo::Resources::Post.new(record: post_form.object, view: :edit)
    field = Avo::Fields::TextField.new(:name, **field_args).hydrate(record: post_form.object, resource:, view: :edit)

    render_inline(Avo::Fields::TextField::EditComponent.new(field:, form: post_form, resource:, **component_args))

    page.find("input[name='post[name]']")
  end

  describe "autofocus" do
    it "focuses the input when the field sets autofocus" do
      expect(render_name_input(autofocus: true)["autofocus"]).to eq "autofocus"
    end

    it "leaves the input alone by default" do
      expect(render_name_input["autofocus"]).to be_nil
    end

    it "evaluates a lambda against the view" do
      expect(render_name_input(autofocus: -> { view.new? })["autofocus"]).to be_nil
    end

    it "lets the caller turn the field's autofocus off" do
      expect(render_name_input(autofocus: true, component_args: {autofocus: false})["autofocus"]).to be_nil
    end
  end
end
