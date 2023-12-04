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

  describe "redirects when no confirmation" do
    it "redirects to hey page" do
      visit "/admin/resources/users"

      click_on "Actions"
      click_on "Test No Confirmation Redirect"

      expect(page).to have_text "hey en"
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
