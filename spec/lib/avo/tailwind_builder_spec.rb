require "rails_helper"

RSpec.describe Avo::TailwindBuilder do
  let(:builder) { described_class.new }
  let(:config) { Avo.configuration }
  let(:input_path) { Rails.root.join("tmp", "avo", "avo.tailwind.input.css") }

  around do |example|
    previous = config.instance_variable_get(:@tailwindcss_content_sources)
    example.run
    config.instance_variable_set(:@tailwindcss_content_sources, previous)
  end

  describe "#generate_input_file" do
    after do
      FileUtils.rm_f(input_path)
    end

    it "includes a host @source for Rails.root/app by default" do
      config.instance_variable_set(:@tailwindcss_content_sources, nil)
      builder.send(:generate_input_file)
      expect(File.read(input_path)).to include(%(@source "../../app"))
    end

    it "includes @source lines for each configured directory" do
      config.tailwindcss_content_sources = [Rails.root.join("app"), Rails.root.join("lib")]
      builder.send(:generate_input_file)
      content = File.read(input_path)
      expect(content).to include(%(@source "../../app"))
      expect(content).to include(%(@source "../../lib"))
    end

    it "resolves entries relative to Rails.root when not absolute" do
      config.tailwindcss_content_sources = ["app"]
      builder.send(:generate_input_file)
      expect(File.read(input_path)).to include(%(@source "../../app"))
    end

    it "does not emit host @source lines when configured as empty" do
      config.tailwindcss_content_sources = []
      builder.send(:generate_input_file)
      expect(File.read(input_path)).not_to include(%(@source "../../app"))
    end
  end
end
