require "rails_helper"

RSpec.describe "Actions", type: :system do
  let!(:user) { create :user }
  let!(:person) { create :person }

  describe "action visibility option" do
    context "index" do
      it "finds an action on index" do
        visit "/admin/resources/users"

        click_on "Actions"

        # Check to see if all the actions are present and which are disabled by default
        expect(page.find("a", text: "Toggle inactive")["data-disabled"]).to eq "true"
        expect(page.find("a", text: "Toggle admin")["data-disabled"]).to eq "true"
        expect(page.find("a", text: "Dummy action")["data-disabled"]).to eq "false"
        expect(page.find("a", text: "Download file")["data-disabled"]).to eq "false"
      end
    end

    context "show" do
      it "does not find an action on show" do
        visit "/admin/resources/users/#{user.id}"

        within "[data-panel-id=\"main\"]" do
          click_on "Actions"
        end

        expect(page).not_to have_link "Dummy action"
        expect(page).to have_link "Toggle inactive"
        expect(page).to have_link "Toggle admin"
        expect(page).to have_link "Download file"
      end
    end

    context "edit" do
      it "finds the action on edit" do
        visit "/admin/resources/users/#{user.id}/edit"

        within "[data-panel-id=\"main\"]" do
          click_on "Actions"
        end

        expect(page).to have_link "Toggle inactive"
        expect(page).to have_link "Toggle admin"
        expect(page).to have_link "Download file"
      end
    end

    context "new" do
      it "finds the action on show" do
        visit "/admin/resources/users/new"

        within "[data-panel-id=\"main\"]" do
          click_on "Actions"
        end

        expect(page).not_to have_link "Toggle inactive"
        expect(page).not_to have_link "Download file"
        expect(page).to have_link "Toggle admin"
      end
    end
  end

  describe "action button should be hidden if no actions present" do
    context "index" do
      it "does not see the actions button" do
        visit "/admin/resources/people"

        expect(page).not_to have_button "Actions"
      end
    end

    context "show" do
      it "does not see the actions button" do
        visit "/admin/resources/people/#{person.id}"

        expect(page).not_to have_button "Actions"
      end
    end
  end

  describe "downloading files" do
    context "without File.open().read" do
      let(:content) { "On the fly dummy content." }
      let(:file_name) { "dummy-content.txt" }

      it "downloads the file and closes the modal" do
        visit "/admin/resources/users"

        click_on "Actions"
        click_on "Download file"
        click_on "Run"

        wait_for_download

        expect(downloaded?).to be true
        expect(download_content).to eq content
        expect(download.split("/").last).to eq file_name
      end
    end

    context "with File.open().read" do
      let(:content) { "Dummy content from the file.\n" }
      let(:file_name) { "dummy-file.txt" }

      it "downloads the file and closes the modal" do
        visit "/admin/resources/users"

        click_on "Actions"
        click_on "Download file"
        check "fields[read_from_file]"
        click_on "Run"

        wait_for_download

        expect(downloaded?).to be true
        expect(download_content).to eq content
        expect(download.split("/").last).to eq file_name
      end
    end

    context "with File.open().read on pdf" do
      let(:file_name) { "dummy-file.pdf" }

      it "downloads the file and closes the modal" do
        visit "/admin/resources/users"

        click_on "Actions"
        click_on "Download file"
        check "fields[read_from_pdf_file]"
        click_on "Run"

        wait_for_download

        expect(downloaded?).to be true
        expect(download_content).to eq File.read(Rails.root.join(file_name))
        expect(download.split("/").last).to eq file_name
      end
    end
  end

  describe "default values" do
    it "displays the default value" do
      visit "/admin/resources/users/#{user.slug}/actions?action_id=Avo::Actions::ToggleInactive"

      expect(page).to have_field "fields[notify_user]", checked: true
      expect(page).to have_field "fields[message]", with: "Your account has been marked as inactive."
    end
  end

  describe "action authorization" do
    it "displays disabled action when not authorized" do
      visit "/admin/resources/users"
      click_on "Actions"
      expect(page.find("a", text: "Dummy action")["data-disabled"]).to eq "false"

      Avo::Actions::Sub::DummyAction.authorize = false
      visit "/admin/resources/users"
      click_on "Actions"
      expect(page).not_to have_link "Dummy action"

      visit "/admin/resources/users/actions?action_id=Avo::Actions::Sub::DummyAction"
      expect(page).to have_text "You are not authorized to perform this action."

      Avo::Actions::Sub::DummyAction.authorize = true
    end
  end

  describe "action close_modal_on_backdrop_click" do
    it "closes the modal on backdrop click" do
      Avo::Actions::ExportCsv.close_modal_on_backdrop_click = true

      visit "/admin/resources/projects"

      click_on "Actions"
      click_on "Export CSV"
      find('[data-modal-target="backdrop"]').trigger("click")

      expect(page).not_to have_selector '[data-controller="modal"]'
    end

    it "does not close the modal on backdrop click" do
      Avo::Actions::ExportCsv.close_modal_on_backdrop_click = false

      visit "/admin/resources/projects"

      click_on "Actions"
      click_on "Export CSV"
      find('[data-modal-target="backdrop"]').trigger("click")

      expect(page).to have_selector '[data-controller="modal"]'

      click_on "Cancel"
      expect(page).not_to have_selector '[data-controller="modal"]'
    end
  end

  describe "redirects when no confirmation" do
    it "redirects to hey page" do
      visit "/admin/resources/users"

      click_on "Actions"
      click_on "Test No Confirmation Redirect"

      expect(page).to have_text "hey en"
    end

    it "redirects to posts and don't redirect when navigating back" do
      visit avo.resources_users_path

      click_on "Actions"
      click_on "Redirect to Posts"

      wait_for_path_to_be(path: avo.resources_posts_path)

      page.go_back

      wait_for_path_to_be(path: avo.resources_users_path)
    end
  end


  describe "do_nothing" do
    it "closes the modal and flashes messages" do
      allow(TestBuddy).to receive(:hi).and_call_original
      expect(TestBuddy).to receive(:hi).with("Hello from Avo::Actions::Test::DoNothing handle method").at_least :once

      visit "/admin/resources/users/new"

      fill_in "user_first_name", with: "First name should persist after action."


      click_on "Actions"
      click_on "Do Nothing"
      expect(page).to have_css("turbo-frame#modal_frame")
      expect(page).to have_selector(modal = "[role='dialog']")
      click_on "Run"
      expect(page).not_to have_selector(modal)
      expect(page).to have_text "Nothing Done!!"
      expect(page).to have_field('user_first_name', with: 'First name should persist after action.')
    end
  end

  describe "close_modal" do
    it "closes the modal and flashes messages" do
      allow(TestBuddy).to receive(:hi).and_call_original
      expect(TestBuddy).to receive(:hi).with("Hello from Avo::Actions::Test::CloseModal handle method").at_least :once

      visit "/admin/resources/users/new"

      fill_in "user_first_name", with: "First name should persist after action."

      expect(page).to have_title("Create new user — Avocadelicious")

      click_on "Actions"
      click_on "Close modal"
      expect(page).to have_css("turbo-frame#modal_frame")
      expect(page).to have_selector(modal = "[role='dialog']")
      click_on "Run"
      expect(page).not_to have_selector(modal)
      expect(page).to have_text "Modal closed!!"
      expect(page).to have_title("Cool title")
      expect(page).to have_field("user_first_name", with: "First name should persist after action.")
    end
  end

  describe "flexibility" do
    context "index" do
      it "finds same action on index with different name" do
        visit "/admin/resources/users"

        click_on "Actions"

        expect(page.find("a", text: "Dummy action")["data-disabled"]).to eq "false"

        visit "/admin/resources/cities"

        click_on "Actions"

        expect(page.find("a", text: "Dummy action city resource")["data-disabled"]).to eq "false"
      end
    end
  end

  # Double download action should keep page
  describe "turbo" do
    let!(:projects) { create_list :project, 4 }
    context "double action" do
      it "page persist" do
        visit "/admin/resources/projects"
        expect(page).to have_css('[data-component-name="avo/views/resource_index_component"]')

        check_select_all
        open_panel_action(action_name: "Export CSV")
        run_action
        expect(page).to have_css('[data-component-name="avo/views/resource_index_component"]')

        open_panel_action(action_name: "Export CSV")
        run_action
        expect(page).to have_css('[data-component-name="avo/views/resource_index_component"]')
      end
    end
  end

  describe "fields" do
    context "boolean group fields" do
      it "pass through fields params" do
        visit avo.resources_users_path

        open_panel_action(action_name: "Dummy action")
        check("fields_fun_switch_sure")

        run_action
        expect(page).to have_text "Sure, I love 🥑"
      end
    end
  end

  describe "fetch fields" do
    it "don't fetch when load index" do
      expect(TestBuddy).not_to receive(:hi).with("Dummy action fields")
      visit avo.resources_users_path
    end

    it "fetch when click on action" do
      expect(TestBuddy).to receive(:hi).with("Dummy action fields").at_least :once
      visit avo.resources_users_path
      open_panel_action(action_name: "Dummy action")
    end
  end

  describe "arguments" do
    it "access to arguments" do
      visit avo.resources_fish_index_path

      open_panel_action(action_name: "Dummy action")

      run_action

      expect(page).not_to have_text "Sure, I love 🥑"
      expect(page).to have_text "I love 🥑"
    end
  end

  describe "callable labels" do
    it "pick label from arguments on run and cancel" do
      encoded_arguments = Avo::BaseAction.encode_arguments({
        cancel_button_label: "Cancel dummy action",
        confirm_button_label: "Confirm dummy action"
      })

      visit "#{avo.resources_users_path}/actions?action_id=Avo::Actions::Sub::DummyAction&arguments=#{encoded_arguments}"

      expect(page).to have_text "Cancel dummy action"
      expect(page).to have_text "Confirm dummy action"
    end
  end

  #   let!(:roles) { { admin: false, manager: false, writer: false } }
  #   let!(:user) { create :user, active: true, roles: roles }

  #   context "index" do
  #     describe "without actions attached" do
  #       let(:url) { "/admin/resources/teams" }

  #       it "does not display the actions button" do
  #         visit url

  #         expect(page).not_to have_text "Actions"
  #       end
  #     end

  #     describe "with actions attached" do
  #       let!(:roles) { { admin: false, manager: false, writer: false } }
  #       let!(:second_user) { create :user, active: true, roles: roles }
  #       let(:url) { "/admin/resources/users" }

  #       it "displays the actions button disabled" do
  #         visit url

  #         expect(page).to have_button("Actions", disabled: true)
  #       end

  #       it "enables the button when selecting a record" do
  #         visit url

  #         expect(page).to have_button("Actions", disabled: true)

  #         find("tr[resource-name=users][resource-id="#{user.id}"] input[type=checkbox]").click

  #         expect(page).to have_button("Actions", disabled: false)
  #       end

  #       it "runs the action" do
  #         visit url

  #         expect(user.active).to be true
  #         expect(second_user.active).to be true

  #         find("tr[resource-name=users][resource-id="#{user.id}"] input[type=checkbox]").click
  #         find("tr[resource-name=users][resource-id="#{second_user.id}"] input[type=checkbox]").click

  #         expect(page).to have_button("Actions", disabled: false)

  #         click_on "Actions"
  #         click_on "Mark inactive"
  #         click_on "Run"

  #         wait_for_loaded

  #         expect(user.reload.active).to be false
  #         expect(second_user.reload.active).to be false
  #       end

  #       it "runs the action without confirmation" do
  #         visit url

  #         expect(user.roles["admin"]).to be false
  #         expect(second_user.roles["admin"]).to be false

  #         find("tr[resource-name=users][resource-id="#{user.id}"] input[type=checkbox]").click
  #         find("tr[resource-name=users][resource-id="#{second_user.id}"] input[type=checkbox]").click

  #         expect(page).to have_button("Actions", disabled: false)

  #         click_on "Actions"
  #         click_on "Make admin"

  #         wait_for_loaded

  #         # expect(page).to have_text "New admin(s) on the board!"
  #         expect(user.reload.roles["admin"]).to be true
  #         expect(second_user.reload.roles["admin"]).to be true
  #       end

  #       describe "when resources still selected" do
  #         it "runs the action" do
  #           visit url

  #           expect(page).to have_button("Actions", disabled: true)

  #           find("tr[resource-name=users][resource-id="#{user.id}"] input[type=checkbox]").click

  #           expect(page).to have_button("Actions", disabled: false)

  #           click_on "Posts"
  #           wait_for_loaded
  #           click_on "Users"
  #           wait_for_loaded

  #           expect(page).to have_button("Actions", disabled: true)
  #         end
  #       end
  #     end
  #   end

  #   context "show" do
  #     let!(:roles) { { admin: false, manager: false, writer: false } }
  #     let!(:user) { create :user, active: true, roles: roles }
  #     let!(:post) { create :post, published_at: nil }

  #     describe "with fields" do
  #       let(:url) { "/admin/resources/users/#{user.id}" }

  #       it "lists the action" do
  #         visit url

  #         click_on "Actions"

  #         expect(find(".js-actions-panel")).to have_text "Mark inactive"
  #       end

  #       it "opens the action modal and executes the action" do
  #         visit url
  #         expect(find_field_value_element("active")).to have_css "svg[data-checked="1"]"

  #         click_on "Actions"
  #         click_on "Mark inactive"

  #         expect(find(".vm--modal")).to have_text "Mark inactive"
  #         expect(find(".vm--modal")).to have_text "Notify user"
  #         expect(find(".vm--modal")).to have_text "Message"
  #         expect(find(".vm--modal #message").value).to eq "Your account has been marked as inactive."

  #         check "notify_user"
  #         fill_in "message", with: "Your account has been marked as very inactive."

  #         click_on "Run"
  #         wait_for_loaded

  #         expect(page).to have_text "Perfect!"
  #         expect(user.reload.active).to be false
  #         expect(find_field_value_element("active")).to have_css "svg[data-checked="0"]"
  #       end

  #       it "executes the action without confirmation" do
  #         visit url

  #         expect(find_field_value_element("roles").find("svg", match: :first)["data-checked"]).to eq "0"

  #         click_on "Actions"
  #         click_on "Make admin"

  #         sleep 0.2
  #         wait_for_loaded

  #         expect(user.reload.roles["admin"]).to be true
  #         expect(find_field_value_element("roles").find("svg", match: :first)["data-checked"]).to eq "1"
  #       end
  #     end

  #     describe "without fields" do
  #       let(:url) { "/admin/resources/posts/#{post.id}" }

  #       it "lists the action with a custom name" do
  #         visit url

  #         click_on "Actions"

  #         expect(find(".js-actions-panel")).to have_text "Toggle post published"
  #       end

  #       it "opens the action modal and executes the action" do
  #         visit url

  #         click_on "Actions"
  #         click_on "Toggle post published"

  #         expect(find(".vm--modal")).to have_text "Toggle post published"
  #         expect(find(".vm--modal")).to have_text "Are you sure, sure?"
  #         expect(find(".vm--modal")).to have_text "Toggle"
  #         expect(find(".vm--modal")).to have_text "Don"t toggle yet"

  #         click_on "Toggle"

  #         expect(page).to have_text "Perfect!"
  #         expect(post.reload.published_at).not_to be nil
  #         expect(current_path).to eq "/admin/resources/posts"
  #       end
  #     end
  #   end
end
