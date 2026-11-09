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

  describe "add-on state" do
    let(:license_class) do
      Struct.new(:valid, :features) do
        def valid? = valid

        def enabled_feature?(name) = features.include?(name)
      end
    end
    let(:plugins) { [double(name: "avo-kanban", gem_name: "avo-kanban", version: "4.3.1")] }

    def render_with(license)
      allow(Avo.plugin_manager).to receive(:plugins).and_return(plugins)
      allow(Avo::Current).to receive(:license).and_return(license)
      allow_any_instance_of(described_class).to receive(:license_gated?).and_return(true)
      with_controller_class(Avo::BaseController) { render_inline(described_class.new) }
    end

    it "marks a paid add-on the valid license doesn't include" do
      result = render_with(license_class.new(true, []))

      expect(result).to have_css(".status-page__plugin-state", text: "Off")
      expect(result).to have_css("[title='Your license doesn\\'t include this add-on, so it\\'s switched off.']")
    end

    it "says the license needs validating when it isn't valid" do
      result = render_with(license_class.new(false, []))

      expect(result).to have_css("[title='Switched off until your license is validated.']")
    end

    it "shows no marker without a license object" do
      expect(render_with(nil)).not_to have_css(".status-page__plugin-state")
    end
  end
end
