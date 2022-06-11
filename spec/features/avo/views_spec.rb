require "rails_helper"

shared_examples "view pages load" do |resource|
  let(:plural_name) { resource.to_s.pluralize }
  let(:record) { create resource }

  context "index" do
    it "loads the page" do
      visit "/admin/resources/#{plural_name}"
    end
  end

  context "new" do
    it "loads the page" do
      visit "/admin/resources/#{plural_name}/new"
    end
  end

  context "show" do
    it "loads the page" do
      visit "/admin/resources/#{plural_name}/#{record.id}"
    end
  end

  context "edit" do
    it "loads the page" do
      visit "/admin/resources/#{plural_name}/#{record.id}/edit"
    end
  end

  context "destroy" do
    it "destroys the record" do
      page.driver.submit :delete, "/admin/resources/#{plural_name}/#{record.id}", {}

      expect {
        record.reload
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "search" do
    it "loads the search page" do
      visit "/admin/avo_api/#{plural_name}/search"
    end
  end
end

RSpec.feature "Views", type: :feature do
  describe "makes sure views load ok" do
    it_behaves_like "view pages load", :comment
    it_behaves_like "view pages load", :course_link
    it_behaves_like "view pages load", :course
    it_behaves_like "view pages load", :fish
    it_behaves_like "view pages load", :person
    it_behaves_like "view pages load", :post
    it_behaves_like "view pages load", :project
    it_behaves_like "view pages load", :review
    it_behaves_like "view pages load", :spouse
    # it_behaves_like "view pages load", :team_membership
    it_behaves_like "view pages load", :team
    it_behaves_like "view pages load", :user
  end
end
