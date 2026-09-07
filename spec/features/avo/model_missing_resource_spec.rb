require "rails_helper"

RSpec.feature "MissingResourceError", type: :feature do
  subject { visit url }

  context "when has_one field" do
    let(:url) { "/admin/resources/stores/#{store.id}/location/#{location.id}?view=show&turbo_frame=has_one_field_show_location&show_location_field=1" }
    let!(:store) { create :store }
    let!(:location) { create :location, store: store }

    it "shows informative error with suggested solution for missing resource" do
      expect {
        subject
      }.to raise_error(Avo::MissingResourceError).with_message "Failed to find a resource while rendering the :location field.\nYou may generate a resource for it by running 'rails generate avo:resource location'.\n\nAlternatively add the 'use_resource' option to the :location field to specify a custom resource to be used.\nMore info on https://docs.avohq.io/4.0/resources.html."
    end
  end

  context "when belongs_to field" do
    let!(:event) { create :event }
    let(:url) { "/admin/resources/events?show_location_field=1" }

    it "shows informative error with suggested solution for missing resource" do
      expect {
        subject
      }.to raise_error.with_message "Failed to find a resource while rendering the :location field.\nYou may generate a resource for it by running 'rails generate avo:resource location'.\n\nAlternatively add the 'use_resource' option to the :location field to specify a custom resource to be used.\nMore info on https://docs.avohq.io/4.0/resources.html."
    end
  end

  context "when has_many field" do
    let!(:team) { create :team }
    let(:url) { "/admin/resources/teams/#{team.id}/locations?turbo_frame=has_many_field_show_locations&show_location_field=1" }

    it "shows informative error with suggested solution for missing resource" do
      expect {
        subject
      }.to raise_error(Avo::MissingResourceError).with_message "Failed to find a resource while rendering the :locations field.\nYou may generate a resource for it by running 'rails generate avo:resource location'.\n\nAlternatively add the 'use_resource' option to the :locations field to specify a custom resource to be used.\nMore info on https://docs.avohq.io/4.0/resources.html."
    end
  end

  context "when has_and_belongs_to_many field" do
    let!(:course) { create :course }
    let(:url) { "/admin/resources/courses/#{course.id}/locations?turbo_frame=has_and_belongs_to_many_field_show_locations&show_location_field=1" }

    it "shows informative error with suggested solution for missing resource" do
      expect {
        subject
      }.to raise_error(Avo::MissingResourceError).with_message "Failed to find a resource while rendering the :locations field.\nYou may generate a resource for it by running 'rails generate avo:resource location'.\n\nAlternatively add the 'use_resource' option to the :locations field to specify a custom resource to be used.\nMore info on https://docs.avohq.io/4.0/resources.html."
    end
  end

  context "when array field" do
    let!(:store) { create :store }
    let(:url) { "/admin/resources/stores/#{store.id}/items?view=show&turbo_frame=array_field_show_items&show_items_field=1" }

    it "shows informative error with suggested solution for missing array resource" do
      expect {
        subject
      }.to raise_error.with_message "Failed to find a resource while rendering the :items field.\nYou may generate a resource for it by running 'rails generate avo:resource item --array'.\n\nAlternatively add the 'use_resource' option to the :items field to specify a custom resource to be used.\nMore info on https://docs.avohq.io/4.0/array-resources.html."
    end
  end
end
