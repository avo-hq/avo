require "herb"
require "herb/engine"

RSpec.describe "HTML templates" do
  it "compile through Herb, which Rails 8.2 uses for ERB by default" do
    templates = Dir[File.expand_path("../../../app/**/*.html.erb", __dir__)]
    expect(templates).not_to be_empty

    failing = templates.reject do |path|
      Herb::Engine.new(File.read(path))
    rescue Herb::Engine::CompilationError
      false
    end

    expect(failing).to be_empty
  end
end
