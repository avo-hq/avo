require "rails_helper"

RSpec.describe "RhinoField CSS leak", type: :system do
  let!(:playground) { Playground.create!(name: "CSS check", lexxy_content: "<p>Hello</p>") }

  it "does not draw the rhino editor border on other fields' trix-content on show" do
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
