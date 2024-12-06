require "rails_helper"

RSpec.describe Avo::TurboStreamActionsHelper, type: :helper do
  let(:turbo_stream) do
    Turbo::Streams::TagBuilder.new(self)
  end

  before do
    @view_context = helper
  end

  describe "#avo_download" do
    subject do
      helper.avo_download(content:, filename:)
    end

    let(:content) { "file content" }
    let(:filename) { "file.txt" }

    it { is_expected.to have_css("turbo-stream[action=\"download\"]") }
    it { is_expected.to have_css("turbo-stream[content=\"file content\"]") }
    it { is_expected.to have_css("turbo-stream[filename=\"file.txt\"]") }
  end

  describe "#avo_flash_alerts" do
    subject do
      helper.avo_flash_alerts
    end

    before do
      allow(helper).to receive(:render).and_return("flash alerts")
      allow(helper).to receive(:flash).and_return(double(discard: {}))
    end

    it { is_expected.to have_css("turbo-stream[action=\"append\"]") }
    it { is_expected.to have_css("turbo-stream[target=\"alerts\"]") }
    it { is_expected.to include("<template>flash alerts</template>") }
  end

  describe "#avo_close_modal" do
    subject do
      helper.avo_close_modal
    end

    it { is_expected.to have_css("turbo-stream[action=\"replace\"]") }
    it { is_expected.to have_css("turbo-stream[target=\"#{Avo::MODAL_FRAME_ID}\"]") }
  end
end
