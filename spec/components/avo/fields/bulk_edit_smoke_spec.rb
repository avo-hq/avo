require "rails_helper"

# Smoke test: every field type that the bulk-update slide-out can plausibly include
# must render without crashing when the EditComponent is instantiated at the
# `:bulk_edit` view (Unit 4).
#
# The goal is regression coverage against accidental hard-coded `selected:` /
# `checked:` / `value:` paths that crash or misbehave when the field's value is nil.
RSpec.describe "bulk_edit view: field-edit smoke", type: :component do
  before(:all) do
    Avo::Current.resource_manager ||= Avo::Resources::ResourceManager.build
  end

  before do
    vc_test_controller.class.helper(Avo::ApplicationHelper)
  end

  let(:user) do
    User.first || begin
      u = User.new(first_name: "Owner", last_name: "Test", email: "owner-#{SecureRandom.hex(4)}@example.com")
      u.password = u.password_confirmation = "secret-password"
      u.save!
      u
    end
  end
  let(:record) { Post.new(name: "Smoke", user: user) }
  let(:resource) { Avo::Resources::Post.new(record:, view: :bulk_edit) }
  let(:form) { ActionView::Helpers::FormBuilder.new(:post, record, vc_test_controller.view_context, {}) }
  let(:view) { Avo::ViewInquirer.new(:bulk_edit) }

  def hydrate(field)
    field.hydrate(record:, resource:, view: view)
  end

  it "renders Text, Select, Boolean, BelongsTo, and Date fields at :bulk_edit without error" do
    fields = [
      [Avo::Fields::TextField.new(:name, name: "Name"), Avo::Fields::TextField::EditComponent],
      [Avo::Fields::SelectField.new(:status, name: "Status", options: {draft: "Draft", published: "Published"}), Avo::Fields::SelectField::EditComponent],
      [Avo::Fields::BooleanField.new(:is_featured, name: "Featured"), Avo::Fields::BooleanField::EditComponent],
      [Avo::Fields::BelongsToField.new(:user, name: "User", use_resource: Avo::Resources::User, can_create: false), Avo::Fields::BelongsToField::EditComponent],
      [Avo::Fields::DateField.new(:created_at, name: "Created at"), Avo::Fields::DateField::EditComponent],
      [Avo::Fields::TextareaField.new(:body, name: "Body"), Avo::Fields::TextareaField::EditComponent]
    ]

    fields.each do |field, component_class|
      hydrate(field)
      expect {
        render_inline(component_class.new(field:, resource:, form:, view: view))
      }.not_to raise_error, "expected #{component_class} to render at :bulk_edit"
    end
  end

  it "use_view_components normalization resolves :bulk_edit to <Field>::EditComponent" do
    text_field = hydrate(Avo::Fields::TextField.new(:name, name: "Name"))
    boolean_field = hydrate(Avo::Fields::BooleanField.new(:is_featured, name: "Featured"))
    belongs_field = hydrate(Avo::Fields::BelongsToField.new(:user, name: "User", use_resource: Avo::Resources::User, can_create: false))

    expect(text_field.component_for_view(:bulk_edit)).to eq Avo::Fields::TextField::EditComponent
    expect(boolean_field.component_for_view(:bulk_edit)).to eq Avo::Fields::BooleanField::EditComponent
    expect(belongs_field.component_for_view(:bulk_edit)).to eq Avo::Fields::BelongsToField::EditComponent
  end
end
