require "rails_helper"

RSpec.describe "HasAndBelongsToManyField", type: :system do
  let!(:user) { create :user }
  let!(:second_user) { create :user }
  let!(:project) { create :project }

  subject do
    visit url
    page
  end

  context "show" do
    let(:url) { "/admin/resources/projects/#{project.id}/users?turbo_frame=has_and_belongs_to_many_field_projects" }

    describe "without a related user" do
      it { is_expected.to have_text "No related record found" }
      it { is_expected.to have_link "Attach user", href: /\/admin\/resources\/projects\/#{project.id}\/users\/new/ }

      it "displays valid links" do
        visit url

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

        expect(current_path).to eql "/admin/resources/projects/#{project.id}/users"
        expect(page).not_to have_text "Choose user"
        expect(page).not_to have_text "No related record found"
      end

      it "removes the modal" do
        visit url

        wait_for_loaded

        click_on "Attach user"

        expect(page).to have_text "Choose user"
        expect(page).to have_select "fields_related_id", selected: "Choose an option"

        select user.name, from: "fields_related_id"

        expect {
          click_on "Cancel"
          wait_for_loaded
        }.not_to change(project.users, :count)

        expect(current_path).to eql "/admin/resources/projects/#{project.id}/users"
        expect(page).not_to have_text "Choose user"
        expect(page).to have_text "No related record found"
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

      it "detaches the user" do
        visit url
        wait_for_loaded

        expect(page).not_to have_text "No related record found"

        expect {
          find("[data-resource-name='users'][data-resource-id='#{user.id}'] [data-control='detach']").click
          page.driver.browser.switch_to.alert.accept
          sleep 0.1
        }.to change(project.users, :count).by(-1)

        expect(current_path).to eql "/admin/resources/projects/#{project.id}/users"
        expect(page).to have_text "No related record found"
      end
    end
  end
end
