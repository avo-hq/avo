require "rails_helper"
require_relative "../../../../lib/generators/avo/eject_generator"

RSpec.feature "eject generator", type: :feature, acquire_lock: :generator do
  let(:overrides_path) { Rails.root.join("app", "assets", "stylesheets", "avo-overrides.css") }

  before do
    allow_any_instance_of(Generators::Avo::EjectGenerator)
      .to receive(:yes?)
      .and_return(true)
  end

  after { FileUtils.rm_f(overrides_path) }

  it "ejects the Avo overrides stylesheet" do
    Rails::Generators.invoke(
      "avo:eject",
      ["--partial", ":avo_overrides", "--skip-avo-version"],
      {destination_root: Rails.root}
    )

    expect(overrides_path).to exist
    expect(overrides_path.read).to be_blank
  end
end
