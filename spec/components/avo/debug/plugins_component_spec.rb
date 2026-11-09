require "rails_helper"

RSpec.describe Avo::Debug::PluginsComponent, type: :component do
  it "links each plugin to its avohq.io gem page, and lists one without a gem by name" do
    plugins = [
      double(name: "avo-kanban", gem_name: "avo-kanban", version: "4.3.1"),
      double(name: "homegrown", gem_name: nil, version: "1.0.0")
    ]
    allow(Avo.plugin_manager).to receive(:plugins).and_return(plugins)

    result = with_controller_class(Avo::BaseController) { render_inline(described_class.new) }

    expect(result).to have_link("avo-kanban", href: "https://avohq.io/gems/avo-kanban")
    expect(result).to have_css("li", text: /avo-kanban\s+4\.3\.1/)
    expect(result).to have_css("li", text: /homegrown\s+1\.0\.0/)
    expect(result).not_to have_link("homegrown")
  end

  describe "row_extra" do
    let(:plugins) { [double(name: "avo-kanban", gem_name: "avo-kanban", version: "4.3.1")] }

    before { allow(Avo.plugin_manager).to receive(:plugins).and_return(plugins) }

    it "renders what the callable returns for each plugin, after its name" do
      row_extra = ->(plugin) { "<em class='extra'>#{plugin.name} extra</em>".html_safe }

      result = with_controller_class(Avo::BaseController) { render_inline(described_class.new(row_extra:)) }

      expect(result).to have_css(".status-page__plugin-name .extra", text: "avo-kanban extra")
    end

    it "renders nothing extra without a callable" do
      result = with_controller_class(Avo::BaseController) { render_inline(described_class.new) }

      expect(result).not_to have_css(".extra")
    end
  end
end
