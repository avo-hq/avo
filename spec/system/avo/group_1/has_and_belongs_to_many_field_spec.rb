require "rails_helper"

RSpec.describe "HasAndBelongsToManyField", type: :system do
  let!(:user) { create :user }
  let!(:second_user) { create :user }
  let!(:project) { create :project }

  subject do
    visit url
    scroll_to find("#has_and_belongs_to_many_field_show_users")
    page.find("#has_and_belongs_to_many_field_show_users")
  end

  context "show" do
    let(:url) { "/admin/resources/projects/#{project.id}" }

    describe "without a related user" do
      it { is_expected.to have_text "No related record found" }
      it { is_expected.to have_link "Attach user", href: /\/admin\/resources\/projects\/#{project.id}\/users\/new/ }

      it "displays valid links" do
        subject

        wait_for_loaded

        click_on "Attach user"

        expect(page).to have_text "Choose user"
        expect(page).to have_select "fields_related_id", selected: "Choose an option"

        select user.name, from: "fields_related_id"

        expect {
          within '[aria-modal="true"]' do
            click_on "Attach"
          end
          wait_for_loaded
        }.to change(project.users, :count).by 1

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
        expect(page).not_to have_text "Choose user"
        within("#has_and_belongs_to_many_field_show_users") do
          expect(page).not_to have_text "No related record found"
        end
      end

      it "removes the modal" do
        subject

        wait_for_loaded

        click_on "Attach user"

        expect(page).to have_text "Choose user"
        expect(page).to have_select "fields_related_id", selected: "Choose an option"

        select user.name, from: "fields_related_id"

        expect {
          click_on "Cancel"
          wait_for_loaded
        }.not_to change(project.users, :count)
      end

      # it 'attaches two users' do
      #   visit url

      #   wait_for_loaded

      #   click_on 'Attach user'

      #   expect(page).to have_text 'Choose user'
      #   expect(page).to have_select 'fields_related_id', selected: 'Choose an option'

      #   select user.name, from: 'fields_related_id'

      #   expect {
      #     click_on 'Attach & Attach another'
      #     wait_for_loaded
      #   }.to change(project.users, :count).by 1

      #   expect(page).to have_text 'Choose user'
      #   expect(page).to have_select 'fields_related_id', selected: 'Choose an option'

      #   select user.name, from: 'fields_related_id'

      #   expect {
      #     click_on 'Attach'
      #     wait_for_loaded
      #   }.to change(project.users, :count).by 1

      #   expect(current_path).to eql "/admin/resources/projects/#{project.id}"
      #   expect(page).not_to have_text 'Choose user'
      #   expect(page).not_to have_text 'No related users found'
      # end
    end

    describe "with an attached user" do
      before do
        project.users << user
      end

      # The project's other panels are empty and show "No related record found" too, so look inside the users panel.
      it "detaches the user" do
        users_panel = "#has_and_belongs_to_many_field_show_users"
        subject

        expect(page).to have_css("#{users_panel} [data-resource-id='#{user.to_param}']")

        expect {
          accept_custom_alert do
            find("#{users_panel} [data-resource-id='#{user.to_param}'] [data-control='detach']").click
          end
          expect(page).to have_css(users_panel, text: "No related record found")
        }.to change(project.users, :count).by(-1)

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
      end
    end
  end
end
