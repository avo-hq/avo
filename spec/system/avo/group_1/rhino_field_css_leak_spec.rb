require "rails_helper"

RSpec.describe "RhinoField CSS leak", type: :system do
  let!(:playground) { Playground.create!(name: "CSS check", lexxy_content: "<p>Hello</p>") }

  it "does not draw the rhino editor border on other fields' trix-content on show" do
    skip "Lexxy requires Rails >= 8.0.2" unless defined?(Lexxy)
    # Fixed in avo-rhino_field > 4.0.4 (avo-hq/avo-rhino_field#8).
    skip "rhino <= 4.0.4 leaks .trix-content styles" if Avo::RhinoField::VERSION <= "4.0.4"

    visit "/admin/resources/playgrounds/#{playground.id}"

    styles = page.evaluate_script <<~JS
      (() => {
        const el = document.querySelector('[data-field-id="lexxy_content"] .trix-content')
        const cs = getComputedStyle(el)
        return {borderStyle: cs.borderStyle, minHeight: cs.minHeight, padding: cs.padding}
      })()
    JS

    expect(styles["borderStyle"]).to eq "none"
    expect(styles["minHeight"]).to eq "0px"
    expect(styles["padding"]).to eq "0px"
  end
end
