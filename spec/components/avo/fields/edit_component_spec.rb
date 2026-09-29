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

    describe "on select fields" do
      before { Avo::Current.resource_manager = Avo::Resources::ResourceManager.build }

      def render_edit(record, field)
        form = ActionView::Helpers::FormBuilder.new(record.model_name.param_key, record, vc_test_controller.view_context, {})
        resource = Avo.resource_manager.get_resource_by_model_class(record.class).new(record:, view: :edit)
        field.hydrate(record:, resource:, view: :edit)

        render_inline(field.component_for_view(:edit).new(field:, form:, resource:))
      end

      it "focuses the country select" do
        render_edit(Project.new, Avo::Fields::CountryField.new(:country, autofocus: true))

        expect(page).to have_css("select[name='project[country]'][autofocus]")
      end

      it "focuses the belongs_to select" do
        render_edit(Post.new, Avo::Fields::BelongsToField.new(:user, autofocus: true))

        expect(page).to have_css("select[name='post[user_id]'][autofocus]")
      end

      it "focuses the type select of a polymorphic belongs_to, not the id selects it clones later" do
        render_edit(Comment.new, Avo::Fields::BelongsToField.new(:commentable, polymorphic_as: :commentable, types: [::Post, ::Project], autofocus: true))

        # Scan the markup: the id selects sit inside <template>s, which the page matchers cannot see into.
        expect(rendered_content.scan(/<select[^>]*>/).size).to be > 1
        expect(rendered_content.scan(/<select[^>]*autofocus[^>]*>/)).to contain_exactly(a_string_including('name="comment[commentable_type]"'))
      end
    end
  end
end
