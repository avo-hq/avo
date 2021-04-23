require "rails_helper"

RSpec.feature "ProgressBar", type: :system do
  let!(:project) { create :project, progress: 27 }

  before do
    visit url
  end

  subject { find("[data-resource-id='#{project.id}'] [data-field-id='progress']") }

  describe "field" do
    context "index" do
      let(:url) { "/avo/resources/projects/" }

      it { is_expected.to have_css "progress[min='0'][max='100'][value='27']" }
      it { is_expected.to have_text "27%" }
    end

    context "show" do
      let(:url) { "/avo/resources/projects/#{project.id}" }
      subject { find_field_value_element "progress" }

      it { is_expected.to have_css "progress[min='0'][max='100'][value='27']" }
      it { is_expected.to have_text "27%" }
    end

    context "edit" do
      let(:url) { "/avo/resources/projects/#{project.id}/edit" }
      subject { find_field_value_element "progress" }

      it { is_expected.to have_css "input[type='range'][min='0'][max='100'][value='27']" }
      it { is_expected.to have_text "27%" }
    end
  end
end
