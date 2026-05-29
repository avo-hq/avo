require "rails_helper"

RSpec.describe Avo::Fields::BelongsToField::EditComponent, type: :component do
  before(:all) do
    # `Avo.resource_manager` is populated via `Avo.init`, which fires on each
    # web request. Component tests bypass the request cycle, so we initialize
    # the resource manager up front. Without it, `BelongsToField#options`
    # raises NoMethodError on a nil `Avo.resource_manager`.
    Avo::Current.resource_manager ||= Avo::Resources::ResourceManager.build
  end

  before do
    # The component calls `helpers.input_classes`, which lives in `Avo::ApplicationHelper`.
    # ViewComponent's `helpers` proxy reflects the controller's helpers; in component
    # specs we register Avo's helpers on the test controller so the lookup succeeds.
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
  let(:record) { Post.new(name: "Post one", user: user) }
  let(:resource) { Avo::Resources::Post.new(record:, view: :edit) }
  let(:form) { ActionView::Helpers::FormBuilder.new(:post, record, vc_test_controller.view_context, {}) }

  def build_field(view: :edit)
    field = Avo::Fields::BelongsToField.new(:user, name: "User", use_resource: Avo::Resources::User, can_create: false)
      .hydrate(record:, resource:, view: Avo::ViewInquirer.new(view.to_s))
    allow(field).to receive(:can_create?).and_return(false)
    field
  end

  def render_component(view: :edit)
    field = build_field(view: view)
    component = described_class.new(field:, resource:, form:, view: Avo::ViewInquirer.new(view.to_s))
    render_inline(component)
  end

  context "default :edit view" do
    it "renders the select with the record's value preselected" do
      render_component(view: :edit)

      select = page.find("select[name='post[user_id]']")
      selected_option = select.find("option[selected]", match: :first)

      expect(selected_option.value).to eq(user.to_param)
    end

    it "does not wire the bulk-update-field controller" do
      render_component(view: :edit)
      expect(page).not_to have_css("[data-controller~='bulk-update-field']")
    end
  end

  context "when view is :bulk_edit" do
    it "renders the select with the localized Unchanged blank option" do
      render_component(view: :bulk_edit)

      select = page.find("select[name='post[user_id]']")
      blank_option = select.find("option[value='']")

      expect(blank_option.text).to eq(I18n.t("avo.bulk_update.belongs_to.unchanged"))
    end

    it "does not preselect any option" do
      render_component(view: :bulk_edit)

      select = page.find("select[name='post[user_id]']")
      # No option with `selected` should be present (other than the implicit blank).
      expect(select).not_to have_css("option[selected]")
    end

    it "wires the bulk-update-field Stimulus controller AND keeps reload-belongs-to-field wiring" do
      render_component(view: :bulk_edit)

      controller_attr = page.find("[data-controller*='bulk-update-field']")["data-controller"]

      expect(controller_attr).to include("bulk-update-field")
      expect(controller_attr).to include("reload-belongs-to-field")
      expect(page).to have_css("[data-bulk-update-field-key-value='user']")
    end
  end
end
