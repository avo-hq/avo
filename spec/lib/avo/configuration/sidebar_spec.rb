require "rails_helper"

# `config.sidebar` merges over the defaults, so setting one key must not wipe the
# other two. Clamping of `default_width` is covered in
# spec/requests/avo/sidebar_width_request_spec.rb.
RSpec.describe "Avo.configuration.sidebar" do
  around do |example|
    original = Avo.configuration.sidebar
    example.run
    Avo.configuration.sidebar = original
  end

  it "fills in the keys the host didn't set" do
    Avo.configuration.sidebar = {resizable: false}

    expect(Avo.configuration.sidebar).to eq(toggle_visible: true, resizable: false, default_width: 256)
  end

  # `sidebar_toggle_visible` shipped before the hash existed.
  it "keeps the flat sidebar_toggle_visible accessor working" do
    Avo.configuration.sidebar_toggle_visible = false

    expect(Avo.configuration.sidebar[:toggle_visible]).to be false
    expect(Avo.configuration.sidebar_toggle_visible).to be false
  end
end
