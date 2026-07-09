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

  describe ".enabled?" do
    def stub_tailwindcss_rails_version(version)
      fake_spec = Gem::Specification.new { |s|
        s.name = "tailwindcss-rails"
        s.version = version
      }
      allow(Gem).to receive(:loaded_specs).and_return(Gem.loaded_specs.merge("tailwindcss-rails" => fake_spec))
    end

    before do
      allow(config).to receive(:tailwindcss_integration_enabled).and_return(true)
      allow(described_class).to receive(:tailwindcss_available?).and_return(true)
    end

    it "is disabled when the host app bundles tailwindcss-rails below version 4" do
      stub_tailwindcss_rails_version("3.0.0")

      expect(described_class.enabled?).to be false
    end

    it "is enabled when the host app bundles tailwindcss-rails 4 or higher" do
      stub_tailwindcss_rails_version("4.0.0")

      expect(described_class.enabled?).to be true
    end

    it "is enabled when tailwindcss-rails is not bundled at all" do
      allow(Gem).to receive(:loaded_specs).and_return(Gem.loaded_specs.except("tailwindcss-rails"))

      expect(described_class.enabled?).to be true
    end
  end

  describe "#generate_input_file" do
    after do
      FileUtils.rm_f(input_path)
    end

    it "includes a host @source for the default app/ scan when unset" do
      config.instance_variable_set(:@tailwindcss_content_sources, nil)
      builder.send(:generate_input_file)
      expect(File.read(input_path)).to include(%(@source "#{builder.send(:tailwind_path, Rails.root.join("app"))}";))
    end

    it "emits one @source per configured host path" do
      config.tailwindcss_content_sources = [Rails.root.join("app"), Rails.root.join("lib")]
      builder.send(:generate_input_file)
      content = File.read(input_path)
      expect(content).to include(%(@source "#{builder.send(:tailwind_path, Rails.root.join("app"))}";))
      expect(content).to include(%(@source "#{builder.send(:tailwind_path, Rails.root.join("lib"))}";))
    end

    it "resolves entries relative to Rails.root when not absolute" do
      config.tailwindcss_content_sources = ["app"]
      builder.send(:generate_input_file)
      expect(File.read(input_path)).to include(%(@source "#{builder.send(:tailwind_path, Rails.root.join("app"))}";))
    end

    it "emits separate @source lines when a path is outside Rails.root" do
      # Must not use Dir.mktmpdir when TMPDIR is under Rails.root — that makes every path
      # a descendant and incorrectly collapses to a single @source.
      external = Rails.root.parent.join("avo_tailwind_builder_external_scan")
      FileUtils.mkdir_p(external)
      begin
        config.tailwindcss_content_sources = [Rails.root.join("app"), external.to_s]
        builder.send(:generate_input_file)
        content = File.read(input_path)
        expect(content).to include(%(@source "#{builder.send(:tailwind_path, Rails.root.join("app"))}";))
        expect(content).to include(%(@source "#{builder.send(:tailwind_path, external)}";))
      ensure
        FileUtils.rm_rf(external)
      end
    end

    it "does not emit host @source lines when configured as empty" do
      config.tailwindcss_content_sources = []
      builder.send(:generate_input_file)
      content = File.read(input_path)
      expect(content).not_to include(%(@source "#{builder.send(:tailwind_path, Rails.root.join("app"))}";))
      expect(content).not_to include(%(@source "#{builder.send(:tailwind_path, Rails.root)}";))
    end
  end
end
