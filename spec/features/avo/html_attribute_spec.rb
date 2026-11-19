require "rails_helper"

RSpec.feature "HtmlAttributes", type: :feature do
  let(:product) { create :product }
  let(:label) { field_wrapper(:title).find('[data-slot="label"]') }
  let(:content) { field_wrapper(:title).find('[data-slot="value"]') }

  context "on show" do
    before { visit avo.resources_product_path product }

    it "renders the html attributes" do
      expect(content[:class]).to include "bg-gray-50 !text-pink-600"
      expect(label[:class]).to include "bg-gray-50 !text-pink-600"
    end

    it "renders the style attribute on the label and content elements" do
      expect(label[:style]).to include "letter-spacing: 0.5px"
      expect(content[:style]).to include "letter-spacing: 1px"
    end

    it "renders the data attributes on the label and content elements" do
      expect(label["data-show-label-marker"]).to eq "title"
      expect(content["data-show-content-marker"]).to eq "title"
    end

    it "keeps the slot data attributes when the field declares its own data" do
      expect(label["data-slot"]).to eq "label"
      expect(content["data-slot"]).to eq "value"
    end

    it "renders no style attribute for a field without html options" do
      expect(field_wrapper(:price).find('[data-slot="label"]')[:style]).to be_blank
      expect(field_wrapper(:price).find('[data-slot="value"]')[:style]).to be_blank
    end
  end

  context "on edit" do
    before { visit avo.edit_resources_product_path product }

    it "renders the classes, style and data attributes on the label element" do
      expect(label[:class]).to include "bg-gray-100 !text-blue-600"
      expect(label[:style]).to include "letter-spacing: 1.5px"
      expect(label["data-edit-label-marker"]).to eq "title"
      expect(label["data-slot"]).to eq "label"
    end

    it "renders the classes, style and data attributes on the content element" do
      expect(content[:class]).to include "bg-gray-100 !text-blue-600"
      expect(content[:style]).to include "letter-spacing: 2px"
      expect(content["data-edit-content-marker"]).to eq "title"
      expect(content["data-slot"]).to eq "value"
    end
  end

  context "on index" do
    let(:red_team) { create :team, color: "#FF0000" }
    let(:green_team) { create :team, color: "#00FF00" }
    let(:user) { create :user }

    before do
      # Only teams with members show on index page
      [red_team, green_team].each do |team|
        team.team_members << user
      end
    end

    it "evaluates the block syntax" do
      visit avo.resources_teams_path

      expect(field_element_by_resource_id("name", red_team.id)["style"]).to match(/color: #FF0000/)
      expect(field_element_by_resource_id("name", green_team.id)["style"]).to match(/color: #00FF00/)
    end
  end

  context "with the block notation on show" do
    let(:team) { create :team, color: "#FF0000" }

    before { visit avo.resources_team_path team }

    it "evaluates the block syntax for the label and content elements" do
      label = field_wrapper(:name).find('[data-slot="label"]')
      content = field_wrapper(:name).find('[data-slot="value"]')

      expect(label[:style]).to match(/color: #FF0000/)
      expect(label["data-block-label-marker"]).to eq "name"
      expect(content[:style]).to match(/color: #FF0000/)
      expect(content["data-block-content-marker"]).to eq "name"
    end
  end

  context "with the attributes key" do
    let(:user) { create :user }
    let!(:project) { create :project, user: user, progress: 30 }

    after do
      Avo::Resources::Project.restore_items_from_backup
      Avo::Resources::Post.restore_items_from_backup
    end

    it "renders the attributes on the edit inputs" do
      Avo::Resources::Project.with_temporary_items do
        attributes = {edit: {input: {attributes: {title: "Custom", "aria-describedby": "custom-hint"}}}}

        field :name, as: :text, html: attributes
        field :description, as: :textarea, html: attributes
        field :users_required, as: :number, html: attributes
        field :status, as: :select, options: {Done: "done"}, html: attributes
        field :country, as: :country, html: attributes
        field :progress, as: :progress_bar, html: attributes
        field :user, as: :belongs_to, html: attributes
        field :files, as: :files, html: attributes
      end

      visit avo.edit_resources_project_path project

      inputs = [
        "#project_name",
        "#project_description",
        "#project_users_required",
        "#project_status",
        "#project_country",
        "input[type=range][data-progress-bar-field-target=visibleInput]",
        "#project_user_id",
        "input[type=file][name='project[files][]']"
      ]

      inputs.each do |selector|
        input = find(selector, visible: :all)

        expect(input[:title]).to eq("Custom"), selector
        expect(input["aria-describedby"]).to eq("custom-hint"), selector
      end
    end

    it "renders the attributes on the edit inputs of the other native fields" do
      post = create :post, user: user

      Avo::Resources::Post.with_temporary_items do
        attributes = {edit: {input: {attributes: {title: "Custom", "aria-describedby": "custom-hint"}}}}

        field :name, as: :external_image, html: attributes
        field :body, as: :password, html: attributes
        field :slug, as: :status, html: attributes
        field :status, as: :badge, show_on: :edit, html: attributes
        field :is_featured, as: :boolean, html: attributes
        field :user_id, as: :hidden, html: attributes
        field :cover, as: :file, html: attributes
      end

      visit avo.edit_resources_post_path post

      inputs = ["#post_name", "#post_body", "#post_slug", "#post_status", "#post_is_featured", "#post_user_id", "input[type=file][name='post[cover]']"]

      inputs.each do |selector|
        input = find(selector, visible: :all)

        expect(input[:title]).to eq("Custom"), selector
        expect(input["aria-describedby"]).to eq("custom-hint"), selector
      end
    end

    it "keeps the attributes the input already sets from the field's options" do
      Avo::Resources::Project.with_temporary_items do
        field :name, as: :text, placeholder: "Project name", html: {
          edit: {
            input: {
              classes: "custom-input",
              attributes: {maxlength: 40, placeholder: "ignored", class: "ignored", value: "ignored"}
            }
          }
        }
      end

      visit avo.edit_resources_project_path project

      input = find("#project_name")
      expect(input[:maxlength]).to eq "40"
      expect(input[:placeholder]).to eq "Project name"
      expect(input[:value]).to eq project.name
      expect(input[:class]).to include "custom-input"
      expect(input[:class]).not_to include "ignored"
    end

    it "renders the attributes on the wrapper, label and content elements of the edit and show views" do
      Avo::Resources::Project.with_temporary_items do
        field :name, as: :text, html: -> do
          show do
            wrapper { attributes("title" => "Show wrapper", "id" => "ignored") }
            label { attributes(title: "Show label") }
            content { attributes(title: "Show content") }
          end
          edit do
            wrapper { attributes(title: "Edit wrapper") }
            label { attributes(title: "Edit label") }
            content { attributes(title: "Edit content") }
          end
        end
      end

      visit avo.resources_project_path project

      expect(field_wrapper(:name)[:title]).to eq "Show wrapper"
      expect(field_wrapper(:name)[:id]).not_to eq "ignored"
      expect(field_wrapper(:name).find('[data-slot="label"]')[:title]).to eq "Show label"
      expect(field_wrapper(:name).find('[data-slot="value"]')[:title]).to eq "Show content"

      visit avo.edit_resources_project_path project

      expect(field_wrapper(:name)[:title]).to eq "Edit wrapper"
      expect(field_wrapper(:name).find('[data-slot="label"]')[:title]).to eq "Edit label"
      expect(field_wrapper(:name).find('[data-slot="value"]')[:title]).to eq "Edit content"
    end

    it "renders the attributes on the index cell" do
      Avo::Resources::Project.with_temporary_items do
        field :name, as: :text, html: -> do
          index do
            wrapper { attributes { {title: "#{record.name} cell"} } }
          end
        end
      end

      visit avo.resources_projects_path

      expect(field_element_by_resource_id(:name, project.to_param)[:title]).to eq "#{project.name} cell"
    end
  end
end
