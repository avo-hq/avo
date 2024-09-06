require 'rails_helper'

RSpec.feature "Breadcrumbs", type: :feature do
  let!(:project) { create :project }
  let!(:url) { "/admin/resources/projects/#{project.id}/edit" }

  before do
    visit url
  end

  subject { page.body }

  describe "with breadcrumbs" do
    it {
      # Find the breadcrumbs container
      breadcrumbs = find('.breadcrumbs')

      # Verify that the text includes all breadcrumbs
      expect(breadcrumbs).to have_text('Dashboard')
      expect(breadcrumbs).to have_text('Projects')
      expect(breadcrumbs).to have_text(project.name)
      expect(breadcrumbs).to have_text('Edit')

      # Ensure the breadcrumbs are in the correct order
      breadcrumb_order = breadcrumbs.text
      expect(breadcrumb_order).to match(/Dashboard.*Projects.*#{project.name}.*Edit/)
    }
  end

  describe "on a custom tool" do
    let!(:url) { "/admin/custom_tool" }

    it { is_expected.to have_css ".breadcrumbs" }
    it { is_expected.to have_text "Dashboard\n" }
  end
end
