require 'rails_helper'

RSpec.feature "Breadcrumbs", type: :feature do
  let!(:project) { create :project }
  let!(:url) { "/avo/resources/projects/#{project.id}/edit" }

  before do
    visit url
  end

  subject { page.body }

  describe "with breadcrumbs" do
    it { is_expected.to have_css ".breadcrumbs" }
    it { is_expected.to have_text "Dashboard\n  \n\nProjects\n  \n\n#{project.name}\n  \n\nEdit\n" }
  end

  describe "on a custom tool" do
    let!(:url) { "/avo/dashboard" }

    it { is_expected.to have_css ".breadcrumbs" }
    it { is_expected.to have_text "Dashboard\n  \n\nDashboard\n" }
  end
end
