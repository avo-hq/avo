# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LinkToChildResource", type: :feature do
  describe "link_to_child_resource " do
    context "Resource linking to child resources" do
      let!(:sibling) { create :sibling, name: "sibling" }
      it "dispaly records linked to the child resource sibling " do
        PersonResource.link_to_child_resource = true
        visit "/admin/resources/people"
        expect(page).to have_link(href: "/admin/resources/siblings/#{sibling.to_param}")
      end

      it "dispaly records linked to the child resource sibling " do
        PersonResource.link_to_child_resource = false
        visit "/admin/resources/people"
        expect(page).to have_link(href: "/admin/resources/people/#{sibling.to_param}")
      end
    end

    context "Field linking to child resources" do
      let(:paul) { create :sibling, name: "paul" }
      let(:lisa) { create :spouse, name: "lisa" }
      let(:john) { create :person, name: "john", relatives: [lisa, paul] }

      it "display records linked to the child resource sibling " do
        visit "/admin/resources/people/#{john.to_param}/relatives?turbo_frame=has_many_field_show_relatives"
        wait_for_loaded
        expect(current_path).to eql "/admin/resources/people/#{john.to_param}/relatives"
        expect(page).to have_text "demonstrate"
        expect(page).to have_link(href: "/admin/resources/siblings/#{paul.to_param}/edit?via_resource_class=PersonResource&via_resource_id=#{john.to_param}")
        expect(page).to have_link(href: "/admin/resources/spouses/#{lisa.to_param}/edit?via_resource_class=PersonResource&via_resource_id=#{john.to_param}")
      end

      it "display records linked to the parent resource people " do
        visit "/admin/resources/people/#{john.to_param}/peoples?turbo_frame=has_many_field_show_peoples"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/people/#{john.to_param}/peoples"

        expect(page).to have_link(href: "/admin/resources/people/#{paul.to_param}/edit?via_resource_class=PersonResource&via_resource_id=#{john.to_param}")
        expect(page).to have_link(href: "/admin/resources/people/#{lisa.to_param}/edit?via_resource_class=PersonResource&via_resource_id=#{john.to_param}")
      end
    end
  end
end
