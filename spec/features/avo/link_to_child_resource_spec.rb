# frozen_string_literal: true

require "rails_helper"

RSpec.describe "LinkToChildResource", type: :feature do
  around do |example|
    prev_state = Avo::Resources::Person.link_to_child_resource
    # This test expects the fallback to be false
    Avo::Resources::Person.link_to_child_resource = false
    example.run
    Avo::Resources::Person.link_to_child_resource = prev_state
  end

  describe "link_to_child_resource " do
    context "Resource linking to child resources" do
      let!(:sibling) { create :sibling, name: "sibling" }
      it "display records linked to the child resource sibling " do
        Avo::Resources::Person.link_to_child_resource = true
        visit "/admin/resources/people"
        expect(page).to have_link(href: "/admin/resources/siblings/#{sibling.id}")
      end

      it "display records linked to the child resource sibling " do
        Avo::Resources::Person.link_to_child_resource = false
        visit "/admin/resources/people"
        expect(page).to have_link(href: "/admin/resources/people/#{sibling.id}")
      end
    end

    context "Resource show page links to associated resources" do
      let(:paul) { create :sibling, name: "paul" }
      let(:john) { create :person, name: "john", person: paul }
      it "display belongs_to association linked to the child resource if set at resource level" do
        Avo::Resources::Person.link_to_child_resource = true
        visit "/admin/resources/people/#{john.id}"
        wait_for_loaded
        expect(page).to have_link(paul.name, href: "/admin/resources/siblings/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
      end

      it "display belongs_to association linked to the parent class resource if set at resource level" do
        Avo::Resources::Person.link_to_child_resource = false
        visit "/admin/resources/people/#{john.id}"
        wait_for_loaded
        expect(page).to have_link(paul.name, href: "/admin/resources/people/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
      end

      it "display belongs_to association linked to the child resource if set at field level" do
        visit "/admin/resources/people/#{john.id}"
        wait_for_loaded
        expect(page).to have_link(paul.name, href: "/admin/resources/siblings/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
      end

      it "display belongs_to association linked to the parent class resource if set at field level" do
        visit "/admin/resources/people/#{john.id}"
        wait_for_loaded
        expect(page).to have_link(paul.name, href: "/admin/resources/people/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
      end
    end

    context "Field linking to child resources" do
      let(:paul) { create :sibling, name: "paul" }
      let(:lisa) { create :spouse, name: "lisa" }
      let(:john) { create :person, name: "john", relatives: [lisa, paul] }

      it "display records linked to the child resource sibling " do
        visit "/admin/resources/people/#{john.id}/relatives?turbo_frame=has_many_field_show_relatives"
        wait_for_loaded
        expect(current_path).to eql "/admin/resources/people/#{john.id}/relatives"
        expect(page).to have_text "demonstrate"
        expect(page).to have_link(href: "/admin/resources/siblings/#{paul.id}/edit?via_record_id=#{john.to_param}&via_resource_class=Person")
        expect(page).to have_link(href: "/admin/resources/spouses/#{lisa.id}/edit?via_record_id=#{john.to_param}&via_resource_class=Person")
      end

      it "display records linked to the parent resource people " do
        visit "/admin/resources/people/#{john.id}/peoples?turbo_frame=has_many_field_show_peoples"
        wait_for_loaded

        expect(current_path).to eql "/admin/resources/people/#{john.id}/peoples"

        expect(page).to have_link(href: "/admin/resources/people/#{paul.id}/edit?via_record_id=#{john.to_param}&via_resource_class=Person")
        expect(page).to have_link(href: "/admin/resources/people/#{lisa.id}/edit?via_record_id=#{john.to_param}&via_resource_class=Person")
      end

      context "id field" do
        it "links to the parent class resource if link_to_child_resource false at the resource level" do
          Avo::Resources::Person.link_to_child_resource = false
          visit "/admin/resources/people/#{john.id}/peoples?turbo_frame=has_many_field_show_relatives"
          wait_for_loaded
          expect(page).to have_link(paul.name, href: "/admin/resources/people/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
        end

        it "links to the child class resource if link_to_child_resource true at the resource level" do
          Avo::Resources::Person.link_to_child_resource = true
          visit "/admin/resources/people/#{john.id}/peoples?turbo_frame=has_many_field_show_relatives"
          wait_for_loaded
          expect(page).to have_link(paul.name, href: "/admin/resources/siblings/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
        end

        it "links to the parent class resource if link_to_child_resource false at the field level" do
          visit "/admin/resources/people/#{john.id}/peoples?turbo_frame=has_many_field_show_relatives"
          wait_for_loaded
          expect(page).to have_link(paul.name, href: "/admin/resources/people/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
        end

        it "links to the child class resource if link_to_child_resource true at the field level" do
          visit "/admin/resources/people/#{john.id}/relatives?turbo_frame=has_many_field_show_relatives"
          wait_for_loaded
          expect(page).to have_link(paul.name, href: "/admin/resources/siblings/#{paul.id}?via_record_id=#{john.id}&via_resource_class=Person")
        end
      end
    end
  end
end
