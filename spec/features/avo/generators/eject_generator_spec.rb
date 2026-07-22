require "rails_helper"
require_relative "../../../../lib/generators/avo/eject_generator"

RSpec.feature "eject generator", type: :feature, acquire_lock: :generator do
  let(:overrides_path) { Rails.root.join("app", "assets", "stylesheets", "avo-overrides.css") }
  let(:overrides_js_path) { Rails.root.join("app", "assets", "javascripts", "avo-overrides.js") }

  before do
    # Stub the shell's yes? (normal arity) rather than the generator's, which
    # Thor delegates via a `def yes?(*args)` splat that trips rspec-mocks'
    # any_instance handling ("__yes?_without_any_instance__ takes -1 argument").
    allow_any_instance_of(Thor::Shell::Basic)
      .to receive(:yes?)
      .and_return(true)
  end

  after do
    FileUtils.rm_f(overrides_path)
    FileUtils.rm_f(overrides_js_path)
  end

  it "ejects the Avo overrides stylesheet" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":avo_overrides_css", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_path).to exist
    expect(overrides_path.read).to be_blank
  end

  it "ejects the Avo overrides javascript" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":avo_overrides_js", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_js_path).to exist
    expect(overrides_js_path.read).to be_blank
  end

  it "ejects both Avo overrides assets at once" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":asset_overrides", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_path).to exist
    expect(overrides_js_path).to exist
  end
end
