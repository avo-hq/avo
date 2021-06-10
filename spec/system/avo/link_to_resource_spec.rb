require "rails_helper"

RSpec.describe "LinkToResource", type: :system do
  describe "for id field" do
    let!(:project) { create :project }

    context "index" do
      it "displays the projects id as link" do
        visit "/admin/resources/projects"

        expect(find_field_element("id")).to have_selector 'a[title="View project"]'
      end

      it "clicks on the projects id" do
        visit "/admin/resources/projects"

        find('[data-field-id="id"]').find("a").click
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/projects/#{project.id}"
      end
    end
  end

  describe "for gravatar field" do
    let!(:user) { create :user }

    context "index" do
      it "displays the user gravatar as link" do
        visit "/admin/resources/users"

        expect(first('[data-field-type="gravatar"]')).to have_selector 'a[title="View user"]'
      end

      it "clicks on the user gravatar" do
        visit "/admin/resources/users"

        user_id = first('[data-field-type="id"]').find("a").text
        user_slug = User.find(user_id).slug

        first('[data-field-type="gravatar"]').find("a").click
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/users/#{user_slug}"
      end
    end
  end
end
