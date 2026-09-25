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

  describe "#avo_update_belongs_to" do
    subject do
      helper.avo_update_belongs_to(
        relation_name: "user",
        target_name: "post[user_id]",
        target_record_id: "42",
        target_resource_label: "Nested User",
        target_resource_class: "User"
      )
    end

    it { is_expected.to have_css('turbo-stream[action="update-belongs-to"][data-relation-name="user"]') }
    it { is_expected.to have_css('turbo-stream[data-target-name="post[user_id]"][data-target-record-id="42"]') }
  end
end
