require "rails_helper"

RSpec.describe "TestHelpers", type: :system do
  let!(:projects) { create_list :project, 2, stage: nil }
  let!(:users) { create_list :user, 2, :with_post, projects: [projects.first] }
  let!(:fish) { create :fish }

  describe "field_wrapper on self resource" do
    context "index" do
      it "finds the wrapper on table" do
        visit "admin/resources/projects"

        projects.each do |project|
          name_wrapper = index_field_wrapper(id: "name", type: "text", record_id: project.id)
          name_wrapper_without_type = index_field_wrapper(id: "name", record_id: project.id)

          expect(name_wrapper).to eq name_wrapper_without_type
          expect(name_wrapper.text).to eql project.name
        end
      end

      it "finds the wrapper on grid" do
        visit "admin/resources/users?view_type=grid"

        users.each do |user|
          grid_item_wrapper = grid_field_wrapper(record_id: user.to_param)

          expect(grid_item_wrapper.text).to eql user.name
        end
      end
    end

    context "show" do
      it "finds the wrapper" do
        visit "admin/resources/projects"

        projects.each do |project|
          visit "admin/resources/projects/#{project.id}"

          name_wrapper = show_field_wrapper(id: "name", type: "text")
          name_wrapper_without_type = show_field_wrapper(id: "name")

          expect(name_wrapper).to eq name_wrapper_without_type
          expect(name_wrapper.text).to eql "NAME\n#{project.name}"
        end
      end
    end
  end

  describe "field_wrapper on show view related resource" do
    context "index" do
      it "finds the wrapper" do
        visit "admin/resources/projects/#{projects.first.id}"

        has_and_belongs_to_many_users = has_and_belongs_to_many_field_wrapper(id: :users)

        users.each do |user|
          first_name_wrapper = within(has_and_belongs_to_many_users) {
            index_field_wrapper(id: "first_name", type: "text", record_id: user.to_param)
          }

          first_name_wrapper_without_type = within(has_and_belongs_to_many_users) {
            index_field_wrapper(id: "first_name", record_id: user.to_param)
          }

          expect(first_name_wrapper).to eq first_name_wrapper_without_type
          expect(first_name_wrapper.text).to eql user.first_name
        end
      end
    end

    context "show" do
      it "finds the wrapper" do
        users.each do |user|
          visit "admin/resources/users/#{user.id}"
          has_one_post = has_one_field_wrapper(id: :post)

          name_wrapper = within(has_one_post) { show_field_wrapper(id: "name", type: "text") }
          name_wrapper_without_type = within(has_one_post) { show_field_wrapper(id: "name") }

          expect(name_wrapper).to eq name_wrapper_without_type
          expect(name_wrapper.text).to eql "NAME\n#{user.post.name}"
        end
      end
    end
  end

  describe "field_label on self resource" do
    context "index" do
      it "finds the label on table" do
        visit "admin/resources/projects"

        projects.each do |project|
          name_label = index_field_label(id: "name")

          expect(name_label).to eql "NAME"
        end
      end
    end

    context "show" do
      it "finds the label" do
        visit "admin/resources/projects"

        projects.each do |project|
          visit "admin/resources/projects/#{project.id}"

          name_label = show_field_label(id: "name")

          expect(name_label).to eql "NAME"
        end
      end
    end
  end

  describe "field_value on self resource" do
    context "index" do
      it "finds the value on table" do
        visit "admin/resources/projects"

        projects.each do |project|
          name_value = index_field_value(id: "name", type: "text", record_id: project.id)
          name_value_without_type = index_field_value(id: "name", record_id: project.id)

          expect(name_value).to eq name_value_without_type
          expect(name_value).to eql project.name
        end
      end
    end

    context "show" do
      it "find value" do
        visit "admin/resources/projects"

        projects.each do |project|
          visit "admin/resources/projects/#{project.id}"

          name_value = show_field_value(id: "name", type: "text")
          name_value_without_type = show_field_value(id: "name")

          expect(name_value).to eq name_value_without_type
          expect(name_value).to eql project.name
        end
      end
    end
  end

  describe "isolated tests" do
    context "empty_dash" do
      it "finds the empty dash" do
        visit "admin/resources/projects"

        expect(index_field_value(id: "stage", record_id: projects.first.id)).to eq empty_dash
      end
    end

    context "search" do
      it "opens the search box, write and select first result" do
        visit "admin/resources/projects"

        click_resource_search_input
        write_in_search(projects.second.name)
        select_first_result_in_search

        expect(page).to have_current_path "/admin/resources/projects/#{projects.second.id}"
      end
    end

    context "confirm_alert" do
      it "confirms the alert" do
        visit "admin/resources/projects/#{projects.first.id}"
        expect {
          click_on "Delete"
          confirm_alert
          wait_for_loaded
          sleep 0.2
        }.to change(Project, :count).by(-1)
      end
    end

    context "run_action" do
      it "runs the panel action in index" do
        visit "admin/resources/fish"

        check_select_all
        open_panel_action(action_name: "Release fish")
        find("[data-resource-edit-target='messageTrixInput']").set("Hello world")
        run_action

        expect(page).to have_content "#{Fish.count} fish released with message 'Hello world' by ."
      end

      it "runs the panel action in show" do
        visit "admin/resources/fish/#{fish.id}"

        open_panel_action(action_name: "Release fish")
        find("[data-resource-edit-target='messageTrixInput']").set("Hello world")
        run_action

        expect(page).to have_content "1 fish released with message 'Hello world' by ."
      end
    end
  end
end
