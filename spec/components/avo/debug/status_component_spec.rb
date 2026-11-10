require "rails_helper"

RSpec.describe Avo::Debug::StatusComponent, type: :component do
  let(:plugins) { [double(name: "avo-kanban", gem_name: "avo-kanban", version: "4.3.1")] }

  before { allow(Avo.plugin_manager).to receive(:plugins).and_return(plugins) }

  it "shows the community license card when no host fills the license card" do
    result = with_controller_class(Avo::BaseController) { render_inline(described_class.new) }

    expect(result).to have_text("Community")
    expect(result).to have_link("View licenses")
  end

  it "shows a host's license card in the community card's place, beside the same plugin list" do
    component = described_class.new(plugin_row_extra: ->(plugin) { "<em class='extra'>#{plugin.name} extra</em>".html_safe })

    result = with_controller_class(Avo::BaseController) do
      render_inline(component) { |status| status.with_license_card { "<div class='host-card'>Host license</div>".html_safe } }
    end

    expect(result).to have_css(".status-page .host-card", text: "Host license")
    expect(result).not_to have_text("Community")
    expect(result).to have_css(".status-page__plugin-name .extra", text: "avo-kanban extra")
  end
end
