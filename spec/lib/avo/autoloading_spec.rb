require "rails_helper"

# `require_dependency` was deprecated in Rails 8.2 and is removed in Rails 9.
# See https://github.com/rails/rails/pull/56992 and AVO-1105.
#
# Avo's controllers used it to force-load their parent class before Ruby
# resolved the superclass constant. That was only ever needed under the classic
# autoloader; Zeitwerk registers `Avo::ApplicationController` up front, so the
# lookup can no longer fall through to the host app's top-level
# `ApplicationController`.
RSpec.describe "Avo autoloading" do
  describe "require_dependency" do
    it "is not used anywhere in app/ or lib/" do
      offenders = Dir.glob(Avo::Engine.root.join("{app,lib}", "**", "*.rb")).select do |path|
        File.foreach(path).any? { |line| line.match?(/^\s*require_dependency\b/) }
      end

      relative = offenders.map { |path| Pathname.new(path).relative_path_from(Avo::Engine.root).to_s }

      expect(relative).to be_empty,
        "require_dependency is removed in Rails 9. Delete it and fully qualify the superclass instead:\n" \
        "#{relative.map { |path| "  #{path}" }.join("\n")}"
    end
  end

  # This is the assertion that actually has teeth. The dummy app defines its own
  # top-level `ApplicationController`, which is exactly the constant a relative
  # superclass reference inside `module Avo` would silently fall through to.
  describe "controller inheritance" do
    it "has a host-app ApplicationController available to be resolved by mistake" do
      expect(defined?(::ApplicationController)).to eq("constant")
      expect(::ApplicationController).not_to eq(Avo::ApplicationController)
    end

    {
      "Avo::ActionsController" => "Avo::ApplicationController",
      "Avo::AttachmentsController" => "Avo::ApplicationController",
      "Avo::BaseController" => "Avo::ApplicationController",
      "Avo::DebugController" => "Avo::ApplicationController",
      "Avo::HomeController" => "Avo::ApplicationController",
      "Avo::PrivateController" => "Avo::ApplicationController",
      "Avo::SearchController" => "Avo::ApplicationController",
      "Avo::AssociationsController" => "Avo::BaseController",
      "Avo::ChartsController" => "Avo::BaseController",
      "Avo::ResourcesController" => "Avo::BaseController"
    }.each do |controller, expected_parent|
      it "resolves #{controller} to #{expected_parent}, not the host app's" do
        expect(controller.constantize.superclass).to eq(expected_parent.constantize)
      end
    end
  end
end
